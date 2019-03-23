;;;;Time:2019.2.5 17:37 by lscott
;;;;The local path "TheWebApp/aria2/aria2.lisp"

(in-package :web-manager.aria2)

;;;Make event
(defun make-broadcast-event ()
  (make-instance 'broadcast-event))

;;;make client and connect my sever
(defvar *client* (make-client "ws://192.168.0.104:6800/jsonrpc"))
(start-connection *client*)

;;;Create download object

(defgeneric update-download (download)
  (:documentation "Update download. Get the info from sever"))

(defgeneric get-download-info (download key)
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

(defclass download-object ()
  ((id
     :initarg :id
     :reader download-id)
   (url
     :initarg :url
     :reader download-url)
   (gid
     :accessor download-gid)
   (all-data ;This is hash table <:key, value> key::completed-length :dir :download-speed :files :gid :status :total-length
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
  (send *client* (create-send-data (download-id download) "addUri" `((,(download-url download)))))
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
    	(send *client* data)))
  )

(defmethod remove-download ((download download-object))
  (with-json-data 
    (data (download-id download) "remove" `(,(download-gid download))
          #'(lambda (gid) (format t "[Remove:id:~a,gid:~a]~%" (download-id download) gid)))
    (send *client* data)))

(defmethod pause-download ((download download-object))
  (with-json-data 
    (data (download-id download) "pause" `(,(download-gid download))
          #'(lambda (gid) (format t "[Pause:id:~a,gid:~a]~%" (download-id download) gid)))
    (send *client* data)))

(defmethod unpause-download ((download download-object))
  (with-json-data 
    (data (download-id download) "unpause" `(,(download-gid download))
          #'(lambda (gid) (format t "[Unpause:id:~a,gid:~a]~%" (download-id download) gid)))
    (send *client* data)))

(defmethod get-download-info ((download download-object) key)
  (cdr (assoc key (download-data download))))

(on :message *client*
    (lambda (message)
      ;(format t "ThreadName:~a~%" (get-thread-name))
      ;(format t "Client:[message]:~a~%" message)
      (let ((message-list (decode-json-from-string message)))
        (cond 
          ((and (>= (length *client-event-stack*) 1) (assoc ':result message-list))
             ;(format t "Client:[result]:~a~%" (cdr (assoc ':result message-list)))
       		 (funcall (first *client-event-stack*) (cdr (assoc ':result message-list)))
             (pop *client-event-stack*))
          ((assoc ':method message-list)
           ;(format t "[Method:~a], [params:~a]~%" 
           ;        (cdr (assoc ':method message-list)) 
           ;        (cdr (assoc ':params message-list)))
           (event! 
             (gethash (cdr (assoc ':method message-list)) *aria2-event-hash-table*) 
             (cdr (assoc ':params message-list))))))))

(on :close *client*
    (lambda (&key code reason)
      (format t "Closed because '~A' (Code=~A)~%" reason code)))

(on :error *client*
    (lambda (error)
      (format t "Got an error: ~S~%" error)))

(defun make-download (id url)
  (let ((download-one (make-instance 'download-object :id id :url url)))
    download-one))

(defun get-connection-state ()
  (ready-state *client*))

(defun restart-connect ()
  (close-connection *client*)
  (setf *client* (make-client "ws://192.168.0.104:6800/jsonrpc"))
  (start-connection *client*))

(in-package :cl-user)

