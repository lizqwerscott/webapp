;;;;All marco

(in-package :web-manager.aria2)

;;;2019.2.8:Dont use hash-table
(defun create-send-data (id-d method-d params-d)
  (encode-json-to-string `((jsonrpc . "2.0") (method . ,(format nil "aria2.~a" method-d)) (params . ,params-d) (id . ,id-d))))

(defmacro with-json-data ((var data-id data-method data-params fn) &body body)
  `(let ((,var (create-send-data ,data-id ,data-method ,data-params)))
     (queue-append ,fn) ,@body))

(in-package :cl-user)

