(in-package :web-manager.handle)

(defun zip-or-unzip (plist-info)
  (format t "zip-or-unzip~%")
  (let ((zip-files ()) (rar-files ()) (directorys ()))
    (dolist (file (directory (merge-pathnames (make-pathname :name :wild :type :wild) (getf plist-info :y-path))))
      (if (string= (pathname-type file) "zip")
          (setf zip-files (append zip-files (list file)))
          (if (string= (pathname-type file) "rar")
              (setf rar-files (append zip-files (list file)))
              (progn (format t "dir~%") (setf directorys (append directorys (list file)))))))
    (dolist (i zip-files)
      (unzip-file i (getf plist-info :b-path) (getf plist-info :password)))
    (dolist (i rar-files)
      (unrar-file i (getf plist-info :b-path) (getf plist-info :password)))
    (let ((zip-files ())) 
      (dolist (i directorys)
        (format t "movedir~%")
      (setf zip-files (append zip-files (list (move-files i (getf plist-info :b-path))))))
      (zip-file zip-files (getf plist-info :y-path) (getf plist-info :id)))))

(defun handle (plist-info)
  (format t "This is handle, now handle name:~A.~%" (getf plist-info :id))
  (if (getf plist-info :zipp) 
      (zip-or-unzip plist-info)))



(in-package :cl-user)
