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
      (format t "~A~%password:~A;~%" i (getf plist-info :password))
      (unzip-file i (getf plist-info :b-path) (getf plist-info :password)))
    (dolist (i rar-files)
      (unrar-file i (getf plist-info :b-path) (getf plist-info :password)))
    (let ((need-zip-files ())) 
      (dolist (i directorys)
        (format t "movedir;~A~%" i)
        (setf need-zip-files (append need-zip-files (list ;Here TODO 
                                                      (move-files i (getf plist-info :b-path))))))
      (if (= 0 (length need-zip-files)) 
          (format t "the need files-directory is nil~%")
          (zip-file need-zip-files (getf plist-info :y-path) (getf plist-info :id))))))
;;TODO
;;Need change the file path to ./file form;
(defun handle (plist-info)
  (format t "This is handle, now handle name:~A.~%" (getf plist-info :id))
  (if (getf plist-info :zipp) 
      (zip-or-unzip plist-info)))



(in-package :cl-user)
