(in-package :web-manager.head)

;(defparameter *drive-path* "/mnt/myusbdrives/files")
(defparameter *drive-path* (make-pathname :directory '(:absolute :home "test-web" "files")))

(defun get-drive-path ()
  *drive-path*)

(defun run-shell (cmd &optional (isDebug-p nil))
  (if isDebug-p 
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output *standard-output*)
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output nil)))

(defun unrar-file (file path password)
  (run-shell (format nil "./head/unrar-file.zsh ~A ~A ~A" file path password) t))

(defun unzip-file (file path password)
  (format t "file:~A;~%path:~A;~%password:~A;~%" file path password)
  (run-shell (format nil "./head/unzip-file.zsh ~A ~A ~A" file path password)))

(defun zip-file (files path id)
  (format t "zip-file-length:~A;~%" (length files))
  (run-shell (format nil "~A;~A" 
                     (format nil "cd ~A" (namestring path))
                     (do ((i 0 (+ i 1)) 
                          (rc (format nil "zip -r -D ~A.zip" id) (format nil "~A ~A" rc (if (pathname-type (nth i files))
                                                                                            (format nil "./~A.~A" (pathname-name (nth i files)) (pathname-type (nth i files)))
                                                                                            (format nil "./~A" (car (last (cdr (pathname-directory (nth i files)))))))))) 
                         ((= i (length files)) rc)
                         (format t "~A~%" rc))) t))

(defun move-files (files path)
  (format t "move~%")
  (format t "files:~A||path:~A~%" (namestring files) (namestring path))
  (run-shell (format nil "mv ~A ~A" (namestring files) (namestring path)))
  (if (not (pathname-name files)) 
     (merge-pathnames (make-pathname :directory (car (last (pathname-directory files)))) path)
     (merge-pathnames (make-pathname :name (pathname-name files) :type (pathname-type files)) path)))

;(defparameter *drive-path* (make-pathname :directory '(:absolute :home "test-web" "files")))

(in-package :cl-user)

