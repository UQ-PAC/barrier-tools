(declare (context (target arm armv8-a+le)))

(require bits)
(require arm-bits)

(in-package aarch64)


(defmacro log*ri (set op rd rn imm)
  "(log*ri set op rd rn imm) implements the logical operation instruction
   accepting either a W or X register. op is the binary logical operation."
  (set rd (op rn (immediate-from-bitmask imm))))

(defun ANDWri (rd rn imm) (log*ri setw logand rd rn imm))
(defun ANDXri (rd rn imm) (log*ri set$ logand rd rn imm))
(defun EORWri (rd rn imm) (log*ri setw logxor rd rn imm))
(defun EORXri (rd rn imm) (log*ri set$ logxor rd rn imm))
(defun ORRWri (rd rn imm) (log*ri setw logor rd rn imm))
(defun ORRXri (rd rn imm) (log*ri set$ logor rd rn imm))


(defmacro Mop*rrr (set op rd rn rm ra)
  "(Mop*rrr set op rd rn rm ra) implements multiply-add, multiply-subtract
   etc with W or X registers. op is the binary operation used after *."
  (set rd (op ra (* rn rm))))

;; MUL*rr is alias of MADD*rrr and gets converted
(defun MADDWrrr (rd rn rm ra) (Mop*rrr setw + rd rn rm ra))
(defun MADDXrrr (rd rn rm ra) (Mop*rrr set$ + rd rn rm ra))
;; MNEG*rr is alias of MSUB*rrr and gets converted
(defun MSUBWrrr (rd rn rm ra) (Mop*rrr setw - rd rn rm ra))
(defun MSUBXrrr (rd rn rm ra) (Mop*rrr set$ - rd rn rm ra))


(defmacro *DIV*r (set div rd rn rm)
  "(*DIV*r set div rd rn rm) implements the SDIV or UDIV instructions
   on W or X registers, with div set to s/ or / respectively."
  (if (= rm 0)
    (set rd 0)
    (set rd (div rn rm))))

(defun SDIVWr (rd rn rm) (*DIV*r setw s/ rd rn rm))
(defun SDIVXr (rd rn rm) (*DIV*r set$ s/ rd rn rm))
(defun UDIVWr (rd rn rm) (*DIV*r setw /  rd rn rm))
(defun UDIVXr (rd rn rm) (*DIV*r set$ /  rd rn rm))


(defmacro CSop*r (set op rd rn rm cnd)
  "(CSop*r set op rd rn rm cnd) implements the conditional select
   instruction on W or X registers, with op being applied to rm
   when cnd is false."
  (if (condition-holds cnd)
    (set rd rn)
    (set rd (op rm))))

(defun id (arg) (declare (visibility :private)) arg)

(defun CSELWr  (rd rn rm cnd) (CSop*r setw id   rd rn rm cnd))
(defun CSELXr  (rd rn rm cnd) (CSop*r set$ id   rd rn rm cnd))
(defun CSINCWr (rd rn rm cnd) (CSop*r setw +1   rd rn rm cnd))
(defun CSINCXr (rd rn rm cnd) (CSop*r set$ +1   rd rn rm cnd))
(defun CSINVWr (rd rn rm cnd) (CSop*r setw lnot rd rn rm cnd))
(defun CSINVXr (rd rn rm cnd) (CSop*r set$ lnot rd rn rm cnd))
(defun CSNEGWr (rd rn rm cnd) (CSop*r setw neg  rd rn rm cnd))  ;; 2's complement negation
(defun CSNEGXr (rd rn rm cnd) (CSop*r set$ neg  rd rn rm cnd))  ;; 2's complement negation
