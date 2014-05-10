(ql:quickload '(:cl-markup
		:cl-ppcre
		:css-lite
		:drakma
		:hunchentoot
		:ironclad
		:local-time))

(defpackage :cl-sdf-home
  (:nicknames :cl-sdf :sdf-home :sdf :home)
  (:use :common-lisp
	:cl-markup
	:css-lite
	:hunchentoot)
  (:export :main))

(in-package :cl-sdf-home)

(defvar *master-port* 9903)

(defvar *master-acceptor*
  (make-instance 'easy-acceptor :port *master-port*))

(defun init () (start *master-acceptor*))

(defun kill () (stop *master-acceptor*))

(defun test-page ()
  (define-easy-handler (index :uri "/") ()
    (setf (content-type*) "text/html")
    (format nil "~a"
	    (markup:html
	     (:head
	      (:title "nydel.sdf.org"))
	     (:body
	      (:div :id "mainContainer"
		    :style "width: 60%; margin-left: auto; margin-right: auto;"
		    (:h3 "nydel.sdf.org")
		    (:hr)
		    (:p "welcome to nydel's home at sdf.")
		    (:hr)
		    (:pre "put an ad for sdf here.")))))))

(defun main ()
  (init)
  (test-page))
