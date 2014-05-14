(ql:quickload '(:alexandria
		:bordeaux-threads
		:cl-daemonize
		:cl-markup
		:cl-ppcre
		:css-lite
		:drakma
		:hunchentoot
		:ironclad
		:local-time
		:restas
		:sb-posix))

(defpackage :cl-sdf-home
  (:nicknames :cl-sdf :sdf-home :sdf :home)
  (:use :common-lisp
	:alexandria
	:hunchentoot)
  (:export :main))

(in-package :cl-sdf-home)

(defvar *master-port* 9903)

(defvar *master-acceptor*
  (make-instance 'easy-acceptor :port *master-port*))

(defun init () (start *master-acceptor*))

(defun kill () (stop *master-acceptor*))

(defvar *pages* nil)

(defvar *entries* '())

(setf *pages* '(("one" . "this is a page apparently")
		("home" . "this is home page string from *pages* alist")))

(defun pull-page (string)
  (let ((cell (assoc string *pages* :test #'string-equal)))
    (cdr cell)))


(defclass weblog-entry ()
  ((timestamp :accessor timestamp
	      :initarg :timestamp
	      :initform (get-universal-time))
   (title :accessor title
	  :initarg :title)
   (body :accessor body
	 :initarg :body)
   (tags :accessor tags
	 :initarg :tags)))

(defun without-markup (string)
  (ppcre:regex-replace-all ">" 
  (ppcre:regex-replace-all "<" string "&lt;")
  "&gt;"))

(defmethod process-weblog-entry ((entry weblog-entry))
  (setf (slot-value entry 'body) (without-markup (slot-value entry 'body)))
  (setf (slot-value entry 'tags) (ppcre:split "\\s+" (slot-value entry 'tags)))
  (setf (slot-value entry 'timestamp) (local-time:universal-to-timestamp (slot-value entry 'timestamp))))

(defmethod build-weblog-entry ((title string)(body string)(tags string))
  (let ((entry
	 (make-instance 'weblog-entry :title title :body body :tags tags)))
    (process-weblog-entry entry)
    entry))

(defun weblog-page ()
  (define-easy-handler (weblog :uri "/weblog") (title body tags)
    (setf (content-type*) "text/html")
    (push (build-weblog-entry title body tags) *entries*)
    (redirect "/weblogdisplay")))

(defun weblog-form-page ()
  (define-easy-handler (weblogentry :uri "/weblogentry") ()
    (setf (content-type*) "text/html")
    (format nil "~a"
	    (markup:html
	     (:head
	      (:title "weblogentry - nydel.sdf.org"))
	     (:body
	      (:div :id "maincontainer"
		    (:form :action "/weblog" :method "get"
			   (:input :type "text" :name "title")
			   (:textarea :name "body" "")
			   (:input :type "text" :name "tags")
			   (:input :type "submit"))))))))

;; next we need a display page for the weblog entries

(defun format-weblog (entry)
  (let* ((timestamp (slot-value entry 'timestamp))
	 (timestamp-display (local-time:format-timestring nil timestamp :format '((:year 4 #\0) "."
										  (:month 2 #\0) "."
										  (:day 2 #\0) " | "
										  (:hour 2 #\0) ":"
										  (:min 2 #\0) ":"
										  (:sec 2 #\0))))
	(title (slot-value entry 'title))
	(body (slot-value entry 'body))
	(tags (slot-value entry 'tags)))
    (markup:markup (:dl
		    (:dt timestamp-display)
		    (:dd
		     (:img :src (random-elt '("http://nydel.sdf.org/images/idea.png"
					      "http://nydel.sdf.org/images/lisp-logo.png"
					      "http://nydel.sdf.org/images/social.png"
					      "http://nydel.sdf.org/images/turntable.png")) :style "float: left; width: 48px; height: 48px;")
		     (:pre title)
		     (:pre body)
		     (:pre tags))))))

(defun display-weblog-page ()
  (define-easy-handler (weblogdisplay :uri "/weblogdisplay") ()
    (setf (content-type*) "text/html")
    (format nil "~{~a~%~}"
	    (mapcar (lambda (y)
		      (format-weblog y)) *entries*))))

;; then a method to save them and retrieve them etc
;; consider a comments section /after/ that


(defun css-page ()
  (define-easy-handler (css :uri "/css") ()
    (setf (content-type*) "text/css")
    (format nil "~a"
	    (css-lite:css (("html, body, div, p, li")
			   (:font-family "ubuntu mono, verdana, sans-serif"
			    :font-size "10pt"
			    :color "#111111"
			    :padding "1px"
			    :margin "1px"))
			  (("a:link")
			   (:text-decoration "none"))
			  (("a:hover")
			   (:text-decoration "underline"
			    :color "green"))
			  (("a:active")
			   (:text-decoration "underline"
			    :color "darkgreen"))
			  (("a:visited")
			   (:text-decoration "none"))
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
		    (:hr :class "thin")
		    (:hr :class "thin")
		    (:pre "welcome to nydel's home at sdf.")
		    (:hr :class "thin")
		    (:hr :class "thin")
		    (:pre
		     (:ul
		      (:li
		       (:a :href "https://github.com/miercoledi/cl-homepage.git"
			   "cl-homepage") " - this website's common lisp software source on github")
		      (:li
		       (:a :href "http://nydel.sdf.org/phlog-entries/m01-0"
			   "misinformationship 01.0") " - on the 'semper-verum' concept in meme theory")
		      (:li
		       (:a :href "http://meerkat.cc"
			   "meerkat.cc") " - my band's homepage, also see our "
			   (:a :href "https://soundcloud.com/joshuatrout"
			       "soundcloud") " for more meerkat music")))
		    (:hr :class "thin")
		    (:hr :class "thin")
		    (:hr :class "thin")
		    (:pre :style "text-align: center;"
		     (:a :href "http://sdf.lonestar.org"
			 (:img :src "http://roint.sdf1.org/portfolio/decscope.png" :style "width: 200px; height: 90px;")))))))))

(defun main ()
  (init)
  (test-page)
  (css-page))

;; uncomment before interpretation to daemonize!
#|
(defparameter *finished* nil)

(cl-daemonize:daemonize :out "output.log"
			:err "error.log"
			:pid "my.pid"
			:stop (lambda (&rest args)
				(declare (ignore args))
				(setf *finished* t)))

(main)

(loop :do
   (sleep 1)
   (when *finished*
     (kill)
     (sb-ext:exit)))
|#
