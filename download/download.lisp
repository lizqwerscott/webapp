(in-package :web-manager.download)

(defun download-baidu (plist)
  (format t "download in baidu yun.ID:~A~%" (getf plist :id)))

(defun download-common (plist)
  (format t "download in common~%")
  (run-shell (format nil "wget -P ~A ~A" (namestring (getf plist :y-path)) (getf plist :url)) t))

(defun download-local (plist)
  (format t "download in local~%")
  (let ((dir-name (make-next-dir (list "Download" (getf plist :id))
                                 (get-drive-path))))
    (format t "Download local path:~A~%" (namestring dir-name))
    (move-dir-all dir-name (getf plist :path))
    (if (not (directory-e dir-name))
        (delete-empty-directory dir-name)
        (error "the move is error")))
  (format t "download finish~%"))

(defun download (plist)
  (format t "download-all~%")
  (cond ((string= (getf plist :download-type) "common") (download-common plist))
        ((string= (getf plist :download-type) "baidu") (download-baidu plist))
        ((string= (getf plist :download-type) "local") (download-local plist))
        ((not (getf plist :download-type)) (error "download-type is nil")))
  plist)



(in-package :cl-user)
