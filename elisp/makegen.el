;; requires
;; f.el https://github.com/rejeep/f.el

(require 'f)

(defun search-makefile ()
  (cl-labels ((do-search (current-dir)
			 (message "Searching in %s " (f-expand current-dir))
			 (if (not (string= 
				   (f-expand current-dir)
				   "/"))
			     (let ((files
				    (remove-if-not (lambda (f)
						     (string= f "makefile"))
						   (directory-files current-dir))))
			       (message "files %s" (prin1-to-string files))
			       (if files
				   (cl-values
				    (f-expand (format "%s/%s" current-dir (first files)))
				    (file-name-directory (f-expand (format "%s/%s" current-dir (first files)))))
				 (funcall #'do-search ".."))))))
    (funcall #'do-search ".")))

(defun replace-in-string (what with in)
  (replace-regexp-in-string (regexp-quote what) with in nil 'literal))

(defun gen-makefile-object-clause (cpp)
  ;; replaceta fnamesta s/.cpp//
  (let ((fname (replace-in-string ".cpp" "" 
				  (f-filename (first *cpps*)))))
    (format 
  "output/%s.o: src/%s.cpp
	g++ -g -c src/%s.cpp -o output/%s.o"
  fname fname
  fname fname)))

(defun regen-makefile ()
  (interactive)
  (cl-multiple-value-bind (makefile-path makefile-dir) (search-makefile)
    (let ((cpps (remove-if (lambda (path)
			     (or 
			      (cl-search "#" (second *cpps*))
			      (cl-search "~" (second *cpps*))))
			   (file-expand-wildcards (format "%s/src/*.cpp" makefile-dir))))
	  (headers (remove-if (lambda (path)
			     (or 
			      (cl-search "#" (second *cpps*))
			      (cl-search "~" (second *cpps*))))
			      (file-expand-wildcards (format "%s/src/*.h" makefile-dir)))))
      (setq *makefile-dir* makefile-dir)
      (setq *cpps* cpps)
      (setq *hs* headers)
      
    (with-temp-buffer
      (insert (format
"targets := $(wildcard output/*.o)

all: main

%s

main: $(targets)
	g++ -o main $(targets)"
(gen-makefile-object-clause cpps)))
      (write-file makefile-path)))))
    

(provide 'makegen)
