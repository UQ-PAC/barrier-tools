(declare (context (target arm armv8-a+le)))

(require bits)
(require arm-bits)

(in-package aarch64)

(defmacro assert-msg (c s)
  "(assert-msg c s) allows you to assert a condition and print a message on failure."
  (when (not c)
    (msg s)
    (error "Assert_failure")))

(defun highest-set-bit (bitv)
  "(highest-set-bit bitv) returns the greatest index whose bit is set in bitv.
   It requires bitv to be non-zero.
   Modified from ARMv8 ISA pseudocode."
  (assert-msg (not (is-zero bitv)) "highest-set-bit bitv is zero")  ; at least 1 bit must be set
  (let ((i (- (word-width bitv) 1)))
    (while (and (> i 0) (= (select i bitv) 0))
      (decr i))
    i))

(defun replicate (bitv n)
  "(replicate bitv n) returns a bitvector with bitv repeated n times.
   Modified from ARMv8 ISA pseudocode."
  (let ((output 0:0))
    (while (> n 0)
      (decr n)
      (set output (concat output bitv)))
    output))

(defun replicate-to-fill (bitv n)
  "(replicate-to-fill bitv n) returns the result of repeating bitv
   to a total of n bits. Requires that n is a multiple of bitv's length.
   Modified from the bits(N) Replicate(bits(M) x) function from
   ARMv8 ISA pseudocode."
  (let ((bitv-length (word-width bitv)))
    (assert-msg (= 0 (mod n bitv-length)) "replicate-to-fill n not multiple of len(bitv)")
    (replicate bitv (/ n bitv-length))))

(defun zeros (n)
  "(zeros n) returns an empty bitvector of length n.
   Modified from ARMv8 ISA pseudocode."
  (replicate 0:1 n))

(defun ones (n)
  "(ones n) returns a bitvector of length n with all bits set.
   Modified from ARMv8 ISA pseudocode."
  (replicate 1:1 n))

(defun zero-extend (bitv result-length)
  "(zero-extend bitv result-length) returns a bitvector of
   length result-length formed by prepending bitv with zeros.
   Modified from ARMv8 ISA pseudocode."
  (let ((bitv-length (word-width bitv)))
    (assert-msg (>= result-length bitv-length) "zero-extend len(bitv) > result-length")
    (concat
      (zeros (- result-length bitv-length))
      bitv)))

(defun rotate-right (bitv n)
  "(rotate-right bitv n) rotates bitv to the right by n positions.
   Carry-out is ignored.
   Modified from ARMv8 ISA pseudocode."
  (if (= n 0)
    bitv
    (let ((bitv-length (word-width bitv))
          (m (mod n bitv-length)))
      ; need to trim the result of logor.
      (extract (- bitv-length 1) 0
        (logor 
          (rshift bitv m)
          (lshift bitv (- bitv-length m)))))))

(defun decode-bit-masks (immN imms immr immediate)
  "(decode-bit-masks immN imms immr immediate) returns the immediate value
   corresponding to the immN:immr:imms bit pattern within opcodes of
   ARMv8 logical operation instructions like AND, ORR etc.
   I'm not sure what the immediate parameter does, but it's nearly always
   called with true.
   Modified from ARMv8 ISA pseudocode."
  (let ((memory-width 64) ; change to 32 if 32-bit system
        (len (highest-set-bit (concat immN (lnot imms))))
        (levels (zero-extend (ones len) 6))
        (S (logand imms levels))
        (R (logand immr levels))
        (diff (- S R))) ; assuming "6-bit subtract with borrow" is regular 2'c subtraction
    (assert-msg (>= len 1) "decode-bit-masks len < 1")
    (assert-msg (not (and immediate (= levels (logand imms levels)))) "decode-bit-masks long condition")
    (let ((esize (lshift 1 len))
          (d (extract (- len 1) 0 diff))
          (welem (zero-extend (ones (+ S 1)) esize))
          (telem (zero-extend (ones (+ d 1)) esize))
          (wmask (replicate-to-fill (rotate-right welem R) memory-width))
          (tmask (replicate-to-fill telem memory-width)))
      ; it seems like wmask is for logical immediates, and tmask is not used
      ; anywhere in the ISA except for the BFM instruction and its aliases.
      ; we're just returning wmask here.
      ; TODO: can we return tuples in Primus Lisp?
      wmask)))

(defun immediate-from-bitmask (mask)
  "(immediate-from-bitmask mask) returns the immediate value corresponding to
   the given 13-bit mask in the form of N:immr:imms."
  (let ((N (select 12 mask))
        (immr (extract 11 6 mask))
        (imms (extract 5 0 mask)))
    (decode-bit-masks N imms immr true)))
