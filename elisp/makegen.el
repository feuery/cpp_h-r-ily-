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



(defun gen-headers (headers cpp)
  (let ((relevant-headers
	 (with-temp-buffer
	   (insert-file cpp)
	   (beginning-of-buffer)
	   (keep-lines "#include \"")
	   (remove-if (apply-partially #'string= "")
		      (split-string
		       (replace-in-string "\n " ""
					  (replace-in-string "\"" ""
							     (replace-in-string "#include \"" "" (buffer-string))))
		       "\n")))))
    (mapconcat #'identity
	       (remove-if #'null
			  (mapcar (lambda (header)
				    (let ((header-name (format "./%s"
							       (f-filename
								header))))
				      (if (member header-name relevant-headers)
					  (replace-in-string "./" " src/"
							     header-name))))
				  headers))
	       "")))

(defun gen-makefile-object-clause (headers cpp)
  (let ((fname (replace-in-string ".cpp" "" 
				  (f-filename cpp))))
    (format 
  "output/%s.o: %s src/%s.cpp
	$(CC) -g $(cflags) -o output/%s.o -c src/%s.cpp\n\n"
  fname
  (gen-headers headers cpp)
  fname
  fname fname)))

(defun gen-targets (cpp)
  (let ((fname (replace-in-string ".cpp" "" 
				  (f-filename cpp))))
    (format 
     " output/%s.o " fname)))

(defun regen-makefile ()
  (interactive)
  (cl-multiple-value-bind (makefile-path makefile-dir) (search-makefile)
    (let ((cpps (remove-if (lambda (path)
			     (or 
			      (cl-search "#" path)
			      (cl-search "~" path)))
			   (file-expand-wildcards (format "%s/src/*.cpp" makefile-dir))))
	  (headers (remove-if (lambda (path)
			     (or 
			      (cl-search "#" path)
			      (cl-search "~" path)))
			      (file-expand-wildcards (format "%s/src/*.h" makefile-dir)))))
      
    (with-temp-buffer
      (insert (format
	       "#this file is generated by makegen.el https://github.com/feuery/cpp_h-r-ily-/blob/master/elisp/makegen.el
CC := g++
targets := %s

include config.mk

all: main

%s

main: $(targets)
	$(CC) -o $(program_name) -static-libgcc -static-libstdc++ $(libraries) $(targets)"
(mapconcat #'gen-targets cpps "")
(mapconcat (apply-partially #'gen-makefile-object-clause headers) cpps "")))
      (write-file makefile-path)))))
    

(provide 'makegen)
