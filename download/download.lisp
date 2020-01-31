(in-package :web-manager.download)

(defun download-baidu (plist)
  (format t "download in baidu yun"))

(defun download-common (plist)
  (format t "download in common")
  (run-shell (format nil "wget -P ~A ~A" (namestring (getf plist :y-path)) (getf plist :url)) t))

(defun download-local (plist)
  (format t "download in local~%")
  (let ((dir-name (make-pathname :directory (append (pathname-directory (get-drive-path)) '("..") '("Download") `(,(getf plist :id))))))
    (format t "ss:~A~%" (namestring dir-name))
    (dolist (dir-file (directory (merge-pathnames (make-pathname :name :wild :type :wild) dir-name))) 
      (format t "~A~%" (namestring dir-file))
      (move-file dir-file (getf plist :y-path))))
  (format t "download finish~%"))

(defun download (plist)
  (format t "download-all~%")
  (cond ((string= (getf plist :download-type) "common") (download-common plist))
        ((string= (getf plist :download-type) "baidu") (download-baidu plist))
        ((string= (getf plist :download-type) "local") (download-local plist))
        ((not (getf plist :download-type)) (error "download-type is nil"))) plist)



(in-package :cl-user)
