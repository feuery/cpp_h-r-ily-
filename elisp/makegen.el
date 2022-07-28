(defun search-makefile ()
  (cl-labels ((do-search (current-dir)
			 (message "Searching in %s " (file-truename current-dir))
			 (if (not (string= 
				   (file-truename current-dir)
				   "/"))
			     (let ((files
				    (remove-if-not (lambda (f)
						     (string= f "makefile"))
						   (directory-files current-dir))))
			       (message "files %s" (prin1-to-string files))
			       (if files
				   (cl-values
				    (file-truename (first files))
				    (file-name-directory (file-truename (first files))))
				 (funcall #'do-search ".."))))))
    (funcall #'do-search ".")))

(defun regen-makefile ()
  (interactive)
  (cl-multiple-value-bind (makefile-path makefile-dir)  (search-makefile)
    (let ((cpps (directory-files (format "%s" "aaa")





				 makefile
;;     (with-temp-buffer
;;       (insert "
;; targets := $(wildcard output/*.o)

;; all: main

;; output/main.o: src/main.cpp
;; 	g++ -g -c src/main.cpp -o output/main.o

;; main: $(targets)
;; 	g++ -o main $(targets)"
      ))
    

(provide 'makegen)


				    (file-name-directory 
