(in-package :web-manager.handle)


(defun recursive-find-compressed-and-extract (path)
  (dolist (compressed (nth 0 (find-compressed path)))
    (extract compressed (get-directory compressed) "nil"))
  (let ((files-dirs (find-compressed path)))
    (if (nth 2 files-dirs)
        (dolist (dir (nth 2 files-dirs))
          (recursive-find-compressed-and-extract dir))
        (format t "Finish~%"))))

(defun zip-or-unzip (plist-info)
  (format t "zip-or-unzip~%")
  (let ((files-dirs (find-compressed (getf plist-info :y-path))))
    (let ((need-zip-files (append (nth 1 files-dirs) (nth 2 files-dirs)))) 
      (if (= 0 (length need-zip-files)) 
          (format t "the need files-directory is null~%")
          (zip-file need-zip-files (getf plist-info :y-path) (getf plist-info :id)))
      (move-files-or-dirs (append (nth 1 files-dirs) (nth 2 files-dirs)) (getf plist-info :b-path)))
    (if (getf plist-info :zipp) 
        (dolist (i (nth 0 files-dirs))
          (extract i (getf plist-info :b-path) (getf plist-info :password)))))
  (if (getf plist-info :zipp) 
      (recursive-find-compressed-and-extract (getf plist-info :b-path))))

(defun handle (plist-info)
  (format t "This is handle, now handle name:~A.~%" (getf plist-info :id))
  (zip-or-unzip plist-info))


(in-package :cl-user)
