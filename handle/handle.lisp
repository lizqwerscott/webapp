(in-package :web-manager.handle)

(defun move-directory-or-file (dir path)
  (format t "move~%")
  (run-shell (format nil "mv ~A ~A" (namestring dir) (namestring path)))
  (if (not (pathname-name dir)) 
      (merge-pathnames (make-pathname :directory (car (last (pathname-directory dir)))) path)
      (merge-pathnames (make-pathname :name (pathname-name dir) :type (pathname-name dir)) path)))

(defun zip-file (file path)
  (format t "zip-file~%")
  )

(defun unrar-file (file path))

(defun unzip-file (file path)
  ())

(defun zip-or-unzip (plist-info)
  (format t "zip-or-unzip~%")
  (let ((zip-files ()) (rar-files ()) (directorys ()))
    (dolist (file (directory (merge-pathnames (make-pathname :name :wild :type :wild) (getf plist-info :y-path))))
      (if (string= (pathname-type file) "zip")
          (setf zip-files (append zip-files (list file)))
          (if (string= (pathname-type file) "rar")
              (setf rar-file (append zip-files (list file)))
              (progn (format t "dir~%") (setf directorys (append directorys (list file)))))))
    (dolist (i zip-files)
      (unzip-file i (getf plist-info :b-path)))
    (dolist (i rar-files)
      (unrar-file i (getf plist-info :b-path)))
    (dolist (i directorys)
      (format t "movedir~%")
      (zip-file i (move-directory-or-file i (getf plist-info :b-path))))))

(defun handle (plist-info)
  (format t "This is handle, now handle name:~A.~%" (getf plist-info :id))
  (if (getf plist-info :zipp) 
      (zip-or-unzip plist-info)))



(in-package :cl-user)
