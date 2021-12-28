(in-package :web-manager.head)

(defparameter *debug* nil)
(defparameter *drive-path* (make-pathname :defaults "/mnt/myusbdrive/files/"))
;(defparameter *drive-path* (make-pathname :defaults "/home/lizqwer/temp/file-manager/"))
;(defparameter *drive-path* (make-pathname :directory '(:absolute "home" "lizqwer" "test-web" "files")))

(defun get-drive-path ()
  *drive-path*)

(defun set-run-module (&key (debugp nil)) 
  (setf *debug* debugp)
  (if *debug* 
      (setf *drive-path* (make-pathname :directory '(:absolute "home" "lizqwer" "test-web" "files"))) 
      (setf *drive-path* (make-pathname :defaults "/mnt/myusbdrive/files/"))) 
  (web-manager.file:load-table-manager))

(defun run-program-m (program parameter &key (input nil) (output nil))
  #+sbcl (sb-ext:run-program (unix-namestring program) parameter :input input :output output)
  #+clozure (ccl:run-program (unix-namestring program) parameter :input input :output output))

(defun run-shell (cmd &optional (isDebug-p nil))
  (if isDebug-p 
      (run-program-m #P"/bin/sh" (list "-c" cmd) :input nil :output *standard-output*)
      (run-program-m #P"/bin/sh" (list "-c" cmd) :input nil :output nil)))

(defun last1 (lst)
  (car (last lst)))

(defun default-password-p (password) 
  (cond ((string= "default" password) "⑨")
        ((string= "nil" password) "")
        (t password)))

(defun unrar-file (file path password)
  (format t "file:~A;~%path:~A;~%password:~A;~%" file path password)
  (with-current-directory (path) 
    (run-program-m "/usr/bin/unrar" (list "x" (format nil "-p~A" (default-password-p password)) (unix-namestring file)) :input nil :output *standard-output*)))

(defun unzip-file (file path password)
  (format t "file:~A;~%path:~A;~%password:~A;~%" file path password)
  (with-current-directory (path)
    (run-program-m "/usr/bin/unzip"
                   (list (format nil "-P ~A" (default-password-p password))
                         (unix-namestring file)) :input nil :output *standard-output*)))

(defun un7z-file (file path password)
  (format t "file:~A;~%password:~A;~%" file path password)
  (with-current-directory (path)
    (run-program-m "/usr/bin/7z" (list "x" (unix-namestring file) (format nil "-p~A" (default-password-p password))) :input nil :output *standard-output*)))

(defun get-directory (file)
  (make-pathname :directory (pathname-directory file)))

(defun extract (file dir password)
  (cond ((string= "zip" (pathname-type file)) (unzip-file file dir password))
        ((string= "rar" (pathname-type file)) (unrar-file file dir password))
        ((string= "7z" (pathname-type file)) (un7z-file file dir password))
        (t (format t "[ERROR]:the files type is error"))))

(defun zip-file (files path id)
  (format t "zip-file-length:~A;~%" (length files))
  (uiop:with-current-directory (path)
    (format t "NowPath:~A~%" (unix-namestring (uiop:getcwd)))
    (run-program-m "/usr/bin/zip" (append (list "-r" "-D" (format nil "~A.zip" id)) (mapcar #'(lambda (x)
                                                                                                     (if (and (pathname-type x) (pathname-name x))
                                                                                                         (format nil "./~A.~A" (pathname-name x) (pathname-type x))
                                                                                                         (format nil "./~A" (car (last (cdr (pathname-directory x))))))) files)) :input nil :output *standard-output*)))

(defun move-dir-all (directory target)
  (run-shell (format nil
                     "mv ~A/* ~A"
                     (unix-namestring directory)
                     (unix-namestring target))))

(defun find-compressed (path &optional (deepth 0))
  (let ((items (directory-e path))
        (compressed-lst-now nil))
    ;(format t "~A~%" items)
    (when (and items (< deepth 4))
      (dolist (item items)
        (if (directoryp item)
            (setf compressed-lst-now
                  (append compressed-lst-now
                          (find-compressed item (+ deepth 1))))
            (if (find (pathname-type item)
                      '("zip" "rar" "7z")
                      :test #'string=)
                (setf compressed-lst-now
                      (append compressed-lst-now (list item)))))))
    compressed-lst-now))

(defun directory-e (dir)
  (if (not (and (pathname-type dir) (pathname-name dir))) 
      (uiop:directory* (merge-pathnames (make-pathname :name :wild :type :wild) dir))
      (error "var is not a dir")))

(defun make-next-dir (dir-lst path)
  "get the path/dir/"
  (when (directoryp path)
    (merge-pathnames (make-pathname :directory (append (list :relative)
                                                       (if (stringp dir-lst)
                                                           (list dir-lst)
                                                           dir-lst)))
                   path)))

(defun empty-dirp (dir)
  (if (directory-e dir) t nil))

(defun prompt-read (prompt)
  (format t "Input-~A:" prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defun prompt-read-number (prompt)
  (or (parse-integer (prompt-read prompt) :junk-allowed t) 0))

(defun prompt-switch (prompt switchs) 
  (format t "Input-~A:~%" prompt)
  (format t "Switch:")
  (do ((i 1 (+ i 1))
       (iterm switchs (cdr iterm)))
      ((= i (+ (length switchs) 1)) 'done)
      (format t " [~A]~A " i (car iterm)))
  (format t "~%")
  (elt switchs 
       (do ((input (prompt-read-number "Number") (prompt-read-number "Number")))
           ((and (>= input 0) (<= input (length switchs))) (- input 1)))))

(defun want-to-self-input (prompt &optional (switchs nil))
  (if (y-or-n-p (format nil "Do you want to chose ~A" prompt))
      (prompt-switch prompt switchs)
      (prompt-read prompt)))

(defun remove-last (lst)
  (when lst
    (subseq lst 0 (- (length lst) 1))))

(defun get-parents-dir (dir) 
  (make-pathname :directory (remove-last (pathname-directory dir))))

(defun directoryp (dir) 
  (equal dir (get-directory dir)))

(defun update-plist-key (plist key data)
  (setf (getf plist key) data)
  plist)

(defun save-plist-file (data path)
  (when (and (listp data) data)
    (with-open-file (out path
                         :direction :output
                         :if-exists :supersede)
      (with-standard-io-syntax
        (print data out)))))

(defun load-plist-file (path)
  (with-open-file (in path)
    (with-standard-io-syntax
      (read in))))

(defun get-task-save-path (name)
  (make-pathname :name name
                 :type "txt"
                 :defaults (make-next-dir "tasks"
                                          (get-drive-path))))

(in-package :cl-user)

