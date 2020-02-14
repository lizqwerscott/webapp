(in-package :web-manager.head)

(defparameter *drive-path* (make-pathname :defaults "/mnt/myusbdrive/files/"))
;(defparameter *drive-path* (make-pathname :directory '(:absolute :home "test-web" "files")))

(defun get-drive-path ()
  *drive-path*)

(defun run-program-m (program parameter &key (input nil) (output nil))
  #+sbcl (sb-ext:run-program (unix-namestring program) parameter :input input :output output)
  #+clozure (ccl:run-program (unix-namestring program) parameter :input input :output output))

(defun run-shell (cmd &optional (isDebug-p nil))
  (if isDebug-p 
      (run-program-m #P"/bin/sh" (list "-c" cmd) :input nil :output *standard-output*)
      (run-program-m #P"/bin/sh" (list "-c" cmd) :input nil :output nil)))

(defun default-password-p (password) 
  (if (string= "nil" password) "⑨" password))

(defun unrar-file (file path password)
  (format t "file:~A;~%path:~A;~%password:~A;~%" file path password)
  (with-current-directory (path) 
    (run-program-m "/usr/bin/unrar" (list "x" (format nil "-p~A" (default-password-p password)) (unix-namestring file)) :input nil :output *standard-output*)))

(defun unzip-file (file path password)
  (format t "file:~A;~%path:~A;~%password:~A;~%" file path password)
  (with-current-directory (path)
    (run-program-m "/usr/bin/unzip" (list (format nil "-P~A" (default-password-p password)) (unix-namestring file)) :input nil :output *standard-output*)))

(defun un7z-file (file path password)
  (with-current-directory (path)
    (run-program-m "/usr/bin/7z" (list "x" (unix-namestring file) (format nil "-p~A" (default-password-p password))) :input nil :output *standard-output*)))

(defun get-directory (file)
  (let ((directory-string "/")) 
    (dolist (i (cdr (pathname-directory file)))
      (setf directory-string (format nil "~A~A/" directory-string i)))
    directory-string))

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

(defun move-file (file path)
  (format t "move files:~A||path:~A~%" (namestring file) (namestring path))
  (if (pathname-name file)
      (rename-file-overwriting-target file (merge-pathnames (make-pathname :name (pathname-name file) :type (pathname-type file)) path))
      (format t "Not is the file"))
  (if (not (pathname-name file)) 
     (merge-pathnames (make-pathname :directory (car (last (pathname-directory file)))) path)
     (merge-pathnames (make-pathname :name (pathname-name file) :type (pathname-type file)) path)))

(defun move-files (files path)
  (dolist (i files)
    (move-file i path)))

(defun move-dir (dir path)
  (let ((new-path (make-pathname :directory (append (pathname-directory path) (last (pathname-directory dir))))) 
        (files-dirs (find-compressed dir))) 
    (ensure-directories-exist new-path)
    (move-files (append (nth 0 files-dirs) (nth 1 files-dirs)) new-path)
    (if (nth 2 files-dirs)
        (move-dirs (nth 2 files-dirs) new-path)))
  (delete-empty-directory dir))

(defun move-dirs (dirs path)
  (dolist (i dirs)
    (move-dir i path)))

(defun move-file-or-dir (file-or-path target)
  (format t "move-file-or-dir:~A||~A~%" (namestring file-or-path) (namestring target))
  (if (and (pathname-name file-or-path) (pathname-type file-or-path))
      (move-file file-or-path target)
      (move-dir file-or-path target)))

(defun move-files-or-dirs (files-or-dirs target)
  (dolist (i files-or-dirs)
    (move-file-or-dir i target)))

(defun find-compressed (path)
  (let ((compressed ()) (no-compressed ()) (dir ()))
    (dolist (file (directory* (merge-pathnames (make-pathname :name :wild :type :wild) path)))
      (if (and (not (pathname-type file)) (not (pathname-name file)))
          (setf dir (append dir (list file)))
          (let ((ft (pathname-type file))) 
            (if (or (string= ft "zip") (string= ft "rar") (string= ft "7z"))
                (setf compressed (append compressed (list file)))
                (setf no-compressed (append no-compressed (list file)))))))
    (list compressed no-compressed dir)))

;(defparameter *drive-path* (make-pathname :directory '(:absolute :home "test-web" "files")))

(in-package :cl-user)

