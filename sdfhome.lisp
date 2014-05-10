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
	:hunchentoot)
  (:export :main))

(in-package :cl-sdf-home)

(defvar *master-port* 9903)

(defvar *master-acceptor*
  (make-instance 'easy-acceptor :port *master-port*))

(defun init () (start *master-acceptor*))

(defun kill () (stop *master-acceptor*))

(defvar *pages* nil)

(setf *pages* '(("one" . "this is a page apparently")
		("home" . "this is home page string from *pages* alist")))

(defun pull-page (string)
  (let ((cell (assoc string *pages* :test #'string-equal)))
    (cdr cell)))

(defun css-page ()
  (define-easy-handler (css :uri "/css") ()
    (setf (content-type*) "text/css")
    (format nil "~a"
	    (css-lite:css (("html, body, div, p")
			   (:font-family "ubuntu mono, verdana, sans-serif"
			    :font-size "10pt"
			    :color "#111111"
			    :padding "0"
			    :margin "0"))
			   (("div#mainContainer")
			    (:margin-left "auto"
		             :margin-right "auto"
			     :width "60%"))
			   (("hr.thin")
			    (:border "1px solid #000000"
			     :border-top "0"
			     :border-right "0"
			     :border-left "0"
			     :margin "0px"
			     :padding "0px"))))))

(defun test-page ()
  (define-easy-handler (index :uri "/") ()
    (setf (content-type*) "text/html")
    (format nil "~a"
	    (markup:html
	     (:head
	      (:title "nydel.sdf.org")
	      (:link :rel "stylesheet" :type "text/css" :href "http://nydel.sdf.org:9903/css")
	      (:link :rel "shortcut icon" :type "text/png" :href "http://floss.zoomquiet.io/data/20111102224152/lisp_logo_mid.png"))
	     (:body
	      (:div :id "mainContainer"
		    (:h3 "nydel.sdf.org")
		    (:hr :class "thin")
		    (:pre "welcome to nydel's home at sdf.")
		    (:hr :class "thin")
		    (:pre :class "content" (pull-page "home"))
		    (:hr :class "thin")
		    (:pre "put an ad for sdf here.")))))))


(defun main ()
  (init)
  (test-page))
