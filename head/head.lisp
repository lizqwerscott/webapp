(in-package :web-manager.head)

(defun run-shell (cmd &optional (isDebug-p nil))
  (if isDebug-p 
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output *standard-output*)
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output nil)))

(defun unrar-file (file path password)
  (run-shell (format nil "./unrar-file.zsh ~A ~A ~A" file path password) t))

(defun unzip-file (file path password)
  (run-shell (format nil "./unzip-file.zsh ~A ~A ~A" file path password) t))

(defun zip-file (files path id)
  (run-shell (format nil "~A;~A" 
                     (format nil "cd ~A" (namestring path))
                     (do ((i 0 (+ i 1)) 
                          (rc (format nil "zip -r ~A.zip" id) (format nil "~A ~A" rc (namestring (nth i files))))) 
                         ((= i (length files)) rc)
                         (format t "~A~%" rc))) t))

(defun move-files (files path)
  (format t "move~%")
    (run-shell (format nil "mv ~A ~A" (namestring files) (namestring path)))
    (if (not (pathname-name files)) 
      (merge-pathnames (make-pathname :directory (car (last (pathname-directory files)))) path)
      (merge-pathnames (make-pathname :name (pathname-name files) :type (pathname-type files)) path)))

(in-package :cl-user)

