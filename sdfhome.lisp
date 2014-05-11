(ql:quickload '(:bordeaux-threads
		:chirp
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
	:hunchentoot)
  (:export :main))

(in-package :cl-sdf-home)

;(defvar *api-key* "Myl1xO0nbDWpnKYZ7e5m9PPYR")
;(defvar *api-secret* "OxiJRNcGQZCE9ZWviT5IhudZf00eDLFqkg3Ub2Z0wTqGW2m1dp")
;(defvar *oauth-api-key* "Myl1xO0nbDWpnKYZ7e5m9PPYR")
;(defvar *oauth-api-secret* "OxiJRNcGQZCE9ZWviT5IhudZf00eDLFqkg3Ub2Z0wTqGW2m1dp")
;(defvar *oauth-access-token* "21594973-5HIS3sIDi1Xb3ly6WpgG2BGcrpKcHwAZI5M04KAMH")
;(defvar *oauth-access-secret* "c17j8yMW6WsxTFMx4ROBs9dceznDbzRdIdDq56FTavWX8")

;(defun fun1 ()
;  (chirp:initiate-authentication
;   :api-key *api-key*
;   :api-secret *api-secret*))

;(defun set-all-chirp-stuff ()
;  (setf chirp:*oauth-api-key* *oauth-api-key*)
;  (setf chirp:*oauth-api-secret* *oauth-api-secret*)
;  (setf chirp:*oauth-access-token* *oauth-access-token*)
;  (setf chirp:*oauth-access-secret* *oauth-access-secret*))

;(defun set-chirp-credentials ()
;  (set-all-chirp-stuff)
;  (chirp:account/verify-credentials :include-entities t))

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

;(defgeneric build-weblog-entry (title body tags)
;  (format t "~%there was a problem running (build-weblog-entry): went to generic of method!~%~a~a~a" title body tags))

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

;;(defun format-weblog-entry (entry)
;;  (markup:markup (:div 
    
    

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
			   (("p.tweet")
			    (:font-size "09pt"
			     :border "1px solid #666666"
			     :border-radius "5px 5px 5px 5px"
			     :padding "5px"
			     :margin "8px"))
			   (("p.tweettime")
			    (:font-size "06pt"
			     :padding "2px"
			     :margin "3px"))
			   (("p.tweetuser")
			    (:font-size "08pt"
			     :padding "3px"
			     :margin "4px"))
			   (("hr.thin")
			    (:border "1px solid #000000"
			     :border-top "0"
			     :border-right "0"
			     :border-left "0"
			     :margin "0px"
			     :padding "0px"))))))

;(defun get-chirp-home ()
;  (set-chirp-credentials)
;  (let ((timeline
;	 (chirp:statuses/home-timeline))) ;:screen-name "joshuatrout")))
;    (loop for i in timeline collect
;	 (let* ((user (chirp:user i))
;		(screen-name (chirp:screen-name user))
;		(real-name (chirp:name user))
;;		(userid (chirp:id user))
;		(time (chirp:created-at i)))
;	 (concatenate 'string
;		      "<p class='tweettime'>"
;		      (write-to-string time)
;		      "</p>"
;		      "<p class='tweetuser'>"
;		      "by " screen-name " (" real-name ")"
;		      "</p>"
;		      "<p class='tweet'>"
;		      (chirp:text-with-markup i)
;		      "</p>")))))

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
		    (:pre
		     (:a :href "https://github.com/miercoledi/cl-homepage.git"
			 "cl-homepage") " - "
		     (:a :href ""
			 "another link"))
		    (:hr :class "thin")
;		    (get-chirp-home)
		    (:hr :class "thin")
;		    (:pre :class "content" (pull-page "home"))
		    (:hr :class "thin")
		    (:pre "put an ad for sdf here.")))))))


(defparameter *finished* nil)

(cl-daemonize:daemonize :out "output.log"
			:err "error.log"
			:pid "my.pid"
			:stop (lambda (&rest args)
				(declare (ignore args))
				(setf *finished* t)))

(defun main ()
  (init)
  (test-page)
  (css-page))

(main)

(loop :do
   (sleep 1)
   (when *finished*
     (kill)
     (sb-ext:quit)))
