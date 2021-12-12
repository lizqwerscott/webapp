(in-package :web-manager.handle)

(defun handle (plist-info)
  (format t "handle plist:~A~%" plist-info)
  (if (string= (getf plist-info :status) "handle")
      (progn
        (format t "This is handle, now handle name:~A.~%" (getf plist-info :id))
        (do ((files (find-compressed (getf plist-info :path))
                    (find-compressed (getf plist-info :path)))
             (i 0 (+ i 1)))
            ((or (not files) (= i 4)))
          (format t "new search compressed:~A~%" (+ i 1))
          (dolist (file files)
            (format t "extract ~A~%" file)
            (extract file (get-directory file) (getf plist-info :password))
            (format t "delete-file ~A~%" file)
            (delete-file file))
          (sleep 1)
          (format t "finish a compressed~%"))
        (format t "Finish handle")
        (save-plist-file (update-plist-key plist-info
                                           :status
                                           "finish")
                         (get-task-save-path (getf plist-info :id))))
      (format t "already finish~%")))

(in-package :cl-user)
