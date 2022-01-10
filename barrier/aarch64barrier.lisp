(declare (context (target arm armv8-a+le)))

(require bits)
(require arm-bits)

(in-package aarch64)

(defun DMB (option)
  (barrier :dmb option))

(defun DSB (option)
  (barrier :dsb option))

(defun ISB (option)
  ;; strictly speaking, only the sy option is valid and is
  ;; the default option (it can be omitted from the mnemonic).
  ;; still including option here though
  (barrier :isb option))
