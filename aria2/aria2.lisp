;;;;Time:2019.2.5 17:37 by lscott
;;;;The local path "TheWebApp/aria2/aria2.lisp"

;;;make client and connect my sever
(defvar *client* (wsd:make-client "ws://192.168.0.104:6800/jsonrpc"))
(wsd:start-connection *client*)

;;;Create download object

(defgeneric update-download (download)
  (:documentation "Update download. Get the info from sever"))

(defgeneric get-download-info (download)
  (:documentation "Get the all info of download(info about[status, totalLength, completedLength, downloadSpeed])"))

(defgeneric remove-download (download)
  (:documentation "remove"))

(defgeneric pause-download (download)
  (:documentation "pause"))

(defgeneric unpause-download (download)
  (:documentation "unpause"))

(defgeneric get-staus (download key)
  (:documentation "get-staue"))

(defvar *client-event-stack* ()) ;queue :queue-append :pop

(defun queue-append (value)
  (setf *client-event-stack* (append *client-event-stack* (list value))))

(defvar *aria2-event-hash-table* (make-hash-table :test #'equal))
(setf (gethash "aria2.onDownloadStart" *aria2-event-hash-table*) (make-broadcast-event))
(setf (gethash "aria2.onDownloadComplete" *aria2-event-hash-table*) (make-broadcast-event))
(setf (gethash "aria2.onDownloadError" *aria2-event-hash-table*) (make-broadcast-event))
(setf (gethash "aria2.onDownloadPause" *aria2-event-hash-table*) (make-broadcast-event))
(setf (gethash "aria2.onDownloadStop" *aria2-event-hash-table*) (make-broadcast-event))

;;;The json is a big problom, we should make a new function to put hash table re to json and put json to hash-table.
;;;2019.2.8:Dont use hash-table
(defun create-send-data (id-d method-d params-d)
  (cl-json:encode-json-to-string `((jsonrpc . "2.0") (method . ,(format nil "aria2.~a" method-d)) (params . ,params-d) (id . ,id-d))))

;(defun get-json-data (json-str) "return a hash table <:key, value>"
;  (let ((lisp-str (json:decode-json-from-string json-str)) (hash-table (make-hash-table)))
;    (dolist (conss lisp-str)
;      (setf (gethash (car conss) hash-table) (cdr conss))) hash-table))

(defmacro with-json-data ((var data-id data-method data-params fn) &body body)
  `(let ((,var (create-send-data ,data-id ,data-method ,data-params)))
     (queue-append ,fn) ,@body))

(defclass download-object ()
  ((id
     :initarg :id
     :reader download-id)
   (url
     :initarg :url
     :reader download-url)
   (gid
     :accessor download-gid)
   (all-data ;<:key, value> key::completed-length :dir :download-speed :files :gid :status :total-length
     :accessor download-data)
   (status
     :initform "waiting"
     :accessor download-status)
   (total-length
     :initform -1
     :accessor download-total-length)
   (completed-length
     :initform 0
     :accessor download-completed-length)
   (speed
     :initform 0
     :accessor download-speed)
   (dir
     :accessor download-dir)
   (files
     :accessor download-files)))

(defmethod initialize-instance :after ((download download-object) &key)
  (wsd:send *client* (create-send-data (download-id download) "addUri" `((,(download-url download)))))
  (queue-append #'(lambda (gid) 
           (setf (download-gid download) gid) 
           (format t "Success put [gid:~a][id:~a]~%" gid (download-id download))))
  )

(defmethod update-download ((download download-object))
  (when (= (length *client-event-stack*) 0)
  	(with-json-data 
    	(data (download-id download) 
           "tellStatus" `(,(download-gid download) ("gid" "status" "totalLength" "completedLength" "downloadSpeed" "dir" "files"))
           #'(lambda (value) (setf (download-data download) value)))
    	(wsd:send *client* data)))
  )

(defmethod remove-download ((download download-object))
  (with-json-data 
    (data (download-id download) "remove" `(,(download-gid download))
          #'(lambda (gid) (format t "[Remove:id:~a,gid:~a]~%" (download-id download) gid)))
    (wsd:send *client* data)))

(defmethod pause-download ((download download-object))
  (with-json-data 
    (data (download-id download) "pause" `(,(download-gid download))
          #'(lambda (gid) (format t "[Pause:id:~a,gid:~a]~%" (download-id download) gid)))
    (wsd:send *client* data)))

(defmethod unpause-download ((download download-object))
  (with-json-data 
    (data (download-id download) "unpause" `(,(download-gid download))
          #'(lambda (gid) (format t "[Unpause:id:~a,gid:~a]~%" (download-id download) gid)))
    (wsd:send *client* data)))

(defmethod get-staus ((download download-object) key)
  (cdr (assoc key (download-data download))))

(wsd:on :message *client*
    (lambda (message)
      ;(format t "ThreadName:~a~%" (get-thread-name))
      ;(format t "Client:[message]:~a~%" message)
      (let ((message-list (cl-json:decode-json-from-string message)))
        (cond 
          ((and (>= (length *client-event-stack*) 1) (assoc ':result message-list))
             ;(format t "Client:[result]:~a~%" (cdr (assoc ':result message-list)))
       		 (funcall (first *client-event-stack*) (cdr (assoc ':result message-list)))
             (pop *client-event-stack*))
          ((assoc ':method message-list)
           ;(format t "[Method:~a], [params:~a]~%" 
           ;        (cdr (assoc ':method message-list)) 
           ;        (cdr (assoc ':params message-list)))
           (cl-events:event! 
             (gethash (cdr (assoc ':method message-list)) *aria2-event-hash-table*) 
             (cdr (assoc ':params message-list))))))))

(wsd:on :close *client*
    (lambda (&key code reason)
      (format t "Closed because '~A' (Code=~A)~%" reason code)))

(wsd:on :error *client*
    (lambda (error)
      (format t "Got an error: ~S~%" error)))

(defun make-download (id url)
  (let ((download-one (make-instance 'download-object :id id :url url)))
    download-one))

(defun get-connection-state ()
  (wsd:ready-state *client*))

(defun restart-connect ()
  (wsd:close-connection *client*)
  (setf *client* (wsd:make-client "ws://192.168.0.104:6800/jsonrpc"))
  (wsd:start-connection *client*))

(defparameter *blender-url* "https://c.pcs.baidu.com/file/6e64ae94253cd80ae1cfd120a5fc6120?fid=2106310748-250528-164361467291074&rt=pr&sign=FDtAER-DCb740ccc5511e5e8fedcff06b081203-2PHRPM86LxysC%2FHGHKPvmW0%2Fnlk%3D&expires=8h&chkv=0&chkbd=0&chkpc=&dp-logid=940497174643345383&dp-callid=0&dstime=1549775625&r=160071492&vip=0")
(defparameter *yelou-url* "https://c.pcs.baidu.com/file/1984bce3437b31460c7c06442eaac3cd?fid=2106310748-250528-94347640809896&rt=pr&sign=FDtAER-DCb740ccc5511e5e8fedcff06b081203-n8igtQffWi0uDlTnN8k%2FXC9XLTM%3D&expires=8h&chkv=0&chkbd=0&chkpc=&dp-logid=940551796349380888&dp-callid=0&dstime=1549775828&r=340821238&vip=0")
;(defparameter *blender* (make-download "blender" *blender-url*))
;(defparameter *yelou* (make-download "yelou" *yelou-url*))
