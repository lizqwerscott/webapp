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
              (:module "head"
                :serial t
                :components ((:file "head")))
              (:module "file-manager"
                :depends-on ("package" "head")
                :serial t
                :components ((:file "file-manager")))
              (:module "download"
                :depends-on ("package" "head")
                :serial t
                :components ((:file "download")))
              (:module "handle"
                :depends-on ("package" "head") 
                :serial t
                :components ((:file "handle")))
              (:file "main" :depends-on ("handle" "package" "download" "head"))))

