(in-package :web-manager.download)

(defun download-baidu (plist)
  (format t "download in baidu yun"))

(defun download-common (plist)
  (format t "download in common")
  (run-shell (format nil "wget -P ~A ~A" (namestring (getf plist :y-path)) (getf plist :url)) t))

(defun download (plist)
  (format t "download-all~%")
  (cond ((string= (getf plist :download-type) "common") (download-common plist))
        ((string= (getf plist :download-type) "baidu") (download-baidu plist))
        ((not (getf plist :download-type)) (error "download-type is nil"))) plist)



(in-package :cl-user)
