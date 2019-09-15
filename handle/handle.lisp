(in-package :web-manager.handle)

(defun handle(plist-info)
  (format t "This is handle, now handle name:~A.~%" (getf plist-info :id))
  )



(in-package :cl-user)
