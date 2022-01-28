(declare (context (target arm armv8-a+le)))

(require bits)
(require arm-bits)

(in-package aarch64)

(defmacro ORR*ri (set rd rn imm)
  (set rd (logor rn (immediate-from-bitmask imm))))

(defun ORRWri (rd rn imm) (ORR*ri setw rd rn imm))
(defun ORRXri (rd rn imm) (ORR*ri set$ rd rn imm))
