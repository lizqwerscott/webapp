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

(defun un7z-file (file path password)
  (run-shell (format nil "./head/un7z-file.zsh ~A ~A ~A" file path password)))

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
  (run-shell (format nil "~A;~A" 
                     (format nil "cd ~A" (namestring path))
                     (do ((i 0 (+ i 1)) 
                          (rc (format nil "zip -r -D ~A.zip" id) (format nil "~A ~A" rc (if (pathname-type (nth i files))
                                                                                            (format nil "./~A.~A" (pathname-name (nth i files)) (pathname-type (nth i files)))
                                                                                            (format nil "./~A" (car (last (cdr (pathname-directory (nth i files)))))))))) 
                         ((= i (length files)) rc)
                         (format t "~A~%" rc))) t))

(defun move-file (file path)
  (format t "move files:~A||path:~A~%" (namestring file) (namestring path))
  (run-shell (format nil "mv ~A ~A" (namestring file) (namestring path)))
  (if (not (pathname-name file)) 
     (merge-pathnames (make-pathname :directory (car (last (pathname-directory file)))) path)
     (merge-pathnames (make-pathname :name (pathname-name file) :type (pathname-type file)) path)))

(defun move-files (files path)
  (dolist (i files)
    (move-file i path)))

(defun find-compressed (path)
  (let ((compressed ()) (no-compressed ()) (dir ()))
    (dolist (file (directory (merge-pathnames (make-pathname :name :wild :type :wild) path)))
      (if (and (not (pathname-type file)) (not (pathname-name file)))
          (setf dir (append dir (list file)))
          (let ((ft (pathname-type file))) 
            (if (or (string= ft "zip") (string= ft "rar") (string= ft "7z"))
                (setf compressed (append compressed (list file)))
                (setf no-compressed (append no-compressed (list file)))))))
    (list compressed no-compressed dir)))

;(defparameter *drive-path* (make-pathname :directory '(:absolute :home "test-web" "files")))

(in-package :cl-user)

