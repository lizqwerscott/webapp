(in-package :cl-user)

(defpackage #:web-manager.system
  (:use :cl :asdf))

(in-package :web-manager.system)

(defsystem :web-manager
 :version "0.0.0"
 :maintainer "lizqwer scott"
 :author "lizqwer scott"
 :licence "BSD sans advertising clause (see file COPYING for details)"
 :description "web-manager"
 :long-description "the download, zip and file manager."
 :depends-on ("cl-events"
              "lparallel"
              "cl-json"
              "websocket-driver")
 :components ((:file "package")
              (:module "aria2"
                :depends-on ("package")
                :serial t
                :components ((:file "marco")
                             (:file "aria2" :depends-on ("marco"))))
              (:file "main" :depends-on ("package" "aria2"))))
