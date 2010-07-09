(defun enr-point-in-region ()
  (and mark-active
       (>= (point) (region-beginning))
       (<= (point) (region-end))))

(defun enr-surround (&optional with downcase quoted)
  (interactive "sSurround with: \nx")
  (if (enr-point-in-region)
      (if (= (point) (region-beginning))
	  (progn
	    (if downcase
		(downcase-region (region-beginning) (region-end)))
	    (exchange-point-and-mark)
	    (insert "</" with ">")
	    (if quoted
		(insert "'"))
	    (exchange-point-and-mark)
	    (if quoted
		(insert "`"))
	    (insert "<" with ">"))
	(save-excursion
	  (insert "</" with ">")
	  (if quoted
	      (insert "'"))
	  (goto-char (region-beginning))
	  (if quoted
	      (insert "`"))
	  (insert "<" with ">")))

    (if quoted
	(insert "`"))
    (insert "<" with "></" with ">")
    (if quoted
	(insert "'"))
    (backward-char (+ (length with) (if quoted 4 3)))))

(defun enr-surround-face (&optional face downcase quoted)
  (interactive "sSet face: \nx")
  (if (enr-point-in-region)
      (if (= (point) (region-beginning))
	  (progn
	    (if downcase
		(downcase-region (region-beginning) (region-end)))
	    (exchange-point-and-mark)
	    (if quoted
		(progn
		  (insert "'")
		  (backward-char 1)))
	    (facemenu-set-face face (region-beginning) (region-end))
	    (exchange-point-and-mark)
	    (if quoted
		(insert "`")))
	(save-excursion
	  (if quoted
	      (progn
		(insert "'")
		(backward-char 1)))
	  (goto-char (region-beginning))
	  (if quoted
	      (insert "`"))))

    (if quoted
	(insert "`"))
    (if quoted
	(insert "'"))
    (backward-char (if quoted 1 0))
    (facemenu-set-face face)))

;(defun enr-insert-bold ()   (interactive) (enr-surround "bold"))
;(defun enr-insert-italic () (interactive) (enr-surround "italic"))
;(defun enr-insert-fixed ()  (interactive) (enr-surround "fixed"))
;(defun enr-insert-qfixed () (interactive) (enr-surround "fixed" nil t))
(defun enr-insert-bold ()   (interactive) (facemenu-set-bold))
(defun enr-insert-italic () (interactive) (facemenu-set-italic))
(defun enr-insert-fixed ()  (interactive) (facemenu-set-fixed))
(defun enr-insert-default ()  (interactive) (facemenu-set-default))
(defun enr-insert-qfixed () (interactive) (enr-surround-face 'fixed nil t))

(local-set-key [f5]    'enr-insert-italic)
(local-set-key [S-f5]  'enr-insert-bold)
(local-set-key [f6]    'enr-insert-fixed)
(local-set-key [S-f6]  'enr-insert-qfixed)
(local-set-key [f8]    'enr-insert-default)
					
(local-set-key [kp-7]  'occur)
(local-set-key [kp-4]  'fill-paragraph)
