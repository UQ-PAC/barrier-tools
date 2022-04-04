(declare (context (target arm armv8-a+le)))

(require bits)
(require arm-bits)

(in-package aarch64)

(defun barrier-option-to-symbol (barrier-type option)
  (case barrier-type
    :dmb
      (case option
        0b1111 :barrier-dmb-sy
        0b1110 :barrier-dmb-st
        0b1101 :barrier-dmb-ld
        0b1011 :barrier-dmb-ish
        0b1010 :barrier-dmb-ishst
        0b1001 :barrier-dmb-ishld
        0b0111 :barrier-dmb-nsh
        0b0110 :barrier-dmb-nshst
        0b0101 :barrier-dmb-nshld
        0b0011 :barrier-dmb-osh
        0b0010 :barrier-dmb-oshst
        0b0001 :barrier-dmb-oshld
        :barrier-dmb-unknown)
    :dsb
      (case option
        0b1111 :barrier-dsb-sy
        0b1110 :barrier-dsb-st
        0b1101 :barrier-dsb-ld
        0b1011 :barrier-dsb-ish
        0b1010 :barrier-dsb-ishst
        0b1001 :barrier-dsb-ishld
        0b0111 :barrier-dsb-nsh
        0b0110 :barrier-dsb-nshst
        0b0101 :barrier-dsb-nshld
        0b0011 :barrier-dsb-osh
        0b0010 :barrier-dsb-oshst
        0b0001 :barrier-dsb-oshld
        :barrier-dsb-unknown)
    :isb
      :barrier-isb-sy))

(defun DMB (option)
  (special (barrier-option-to-symbol :dmb option)))

(defun DSB (option)
  (special (barrier-option-to-symbol :dsb option)))

(defun ISB (option)
  ;; strictly speaking, only the sy option is valid and is
  ;; the default option (it can be omitted from the mnemonic).
  ;; still including option here though
  (special (barrier-option-to-symbol :dmb option)))
