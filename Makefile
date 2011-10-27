# The system generated date in YYYYMMDD format
DATE = $(shell date "+%Y%m%d")

# The version according to the source file. If this is the nightly build, use a different version
VER = $(shell cat version.txt)

# The command to replace the @VERSION in the files with the actual version
SED_VER = sed "s/@VERSION/$(shell git log -1 --format=format:" Git > Date: %cd Info SHA1: %H")/"
deploy:  SED_VER = sed "s/@VERSION/${VER}/"
MIN_VER = "/*! jQuery Mobile v@VERSION jquerymobile.com | jquery.org/license */"

# The version of jQuery core used
JQUERY = $(shell grep Library js/jquery.js | sed s'/ \* jQuery JavaScript Library v//')

# The directory to create the zipped files in and also serves as the filenames
DIR = jquery.mobile-${VER}
STRUCTUREFILE = jquery.mobile.structure-${VER}
nightly: DIR = jquery.mobile

# The output folder for the finished files
OUTPUT = ../../../public/libs/jqm

# Command to remove the latest directory from the CDN before uploading, only if using latest target
RMLATEST = echo ""

# The output folder for the nightly files.
NIGHTLY_OUTPUT = nightlies/${DATE}
ifeq (${NIGHTLY_OUTPUT}, latest)
	RMLATEST = ssh jqadmin@code.origin.jquery.com 'rm -rf /var/www/html/code.jquery.com/mobile/latest'
endif
NIGHTLY_WEBPATH = http://code.jquery.com/mobile/${NIGHTLY_OUTPUT}

# The filenames
JS = ${DIR}.js
MIN = ${DIR}.min.js
CSS = ${DIR}.css
CSSMIN = ${DIR}.min.css
CSSSTRUCTURE = ${STRUCTUREFILE}.css
CSSSTRUCTUREMIN = ${STRUCTUREFILE}.min.css
CSSTHEME = default

# The files to include when compiling the JS files
JSFILES = 	  js/jquery.ui.widget.js \
			  js/jquery.mobile.widget.js \
			  js/jquery.mobile.media.js \
			  js/jquery.mobile.support.js \
			  js/jquery.mobile.vmouse.js \
			  js/jquery.mobile.event.js \
			  js/jquery.mobile.hashchange.js \
			  js/jquery.mobile.page.js \
			  js/jquery.mobile.core.js \
			  js/jquery.mobile.navigation.js \
			  js/jquery.mobile.navigation.pushstate.js \
			  js/jquery.mobile.transition.js \
			  js/jquery.mobile.degradeInputs.js \
			  js/jquery.mobile.dialog.js \
			  js/jquery.mobile.page.sections.js \
			  js/jquery.mobile.collapsible.js \
			  js/jquery.mobile.fieldContain.js \
			  js/jquery.mobile.grid.js \
			  js/jquery.mobile.navbar.js \
			  js/jquery.mobile.listview.js \
			  js/jquery.mobile.listview.filter.js \
			  js/jquery.mobile.nojs.js \
			  js/jquery.mobile.forms.checkboxradio.js \
			  js/jquery.mobile.forms.button.js \
			  js/jquery.mobile.forms.slider.js \
			  js/jquery.mobile.forms.textinput.js \
			  js/jquery.mobile.forms.select.custom.js \
			  js/jquery.mobile.forms.select.js \
			  js/jquery.mobile.buttonMarkup.js \
			  js/jquery.mobile.controlGroup.js \
			  js/jquery.mobile.links.js \
			  js/jquery.mobile.fixHeaderFooter.js \
			  js/jquery.mobile.fixHeaderFooter.native.js \
			  js/jquery.mobile.init.js

CSSTHEMEFILES = css/themes/${CSSTHEME}/jquery.mobile.theme.css
CSSSTRUCTUREFILES = css/structure/jquery.mobile.core.css \
			  css/structure/jquery.mobile.transitions.css \
			  css/structure/jquery.mobile.grids.css \
			  css/structure/jquery.mobile.headerfooter.css \
			  css/structure/jquery.mobile.navbar.css \
			  css/structure/jquery.mobile.button.css \
			  css/structure/jquery.mobile.collapsible.css \
			  css/structure/jquery.mobile.controlgroup.css \
			  css/structure/jquery.mobile.dialog.css \
			  css/structure/jquery.mobile.forms.checkboxradio.css \
			  css/structure/jquery.mobile.forms.fieldcontain.css \
			  css/structure/jquery.mobile.forms.select.css \
			  css/structure/jquery.mobile.forms.textinput.css \
			  css/structure/jquery.mobile.listview.css \
			  css/structure/jquery.mobile.forms.slider.css


# The files to include when compiling the CSS files
CSSFILES = ${CSSTHEMEFILES} ${CSSSTRUCTUREFILES}

# By default, this is what get runs when make is called without any arguments.
# Min and un-min CSS and JS files are the only things built
all: init js min css cssmin notify

# Build the normal CSS file.
css: init
	# Build the CSS file
	@@head -8 js/jquery.mobile.core.js | ${SED_VER} > ${OUTPUT}/${CSS}
	@@cat ${CSSFILES} >> ${OUTPUT}/${CSS}
	@@head -8 js/jquery.mobile.core.js | ${SED_VER} > ${OUTPUT}/${CSSSTRUCTURE}
	@@cat ${CSSSTRUCTUREFILES} >> ${OUTPUT}/${CSSSTRUCTURE}

# Build the minified CSS file
cssmin: init css
	# Build the minified CSS file
	@@echo ${MIN_VER} | ${SED_VER} > ${OUTPUT}/${CSSMIN}
	@@echo ${MIN_VER} | ${SED_VER} > ${OUTPUT}/${CSSSTRUCTUREMIN}
	@@java -jar build/yuicompressor-2.4.6.jar --type css ${OUTPUT}/${CSS} >> ${OUTPUT}/${CSSMIN}
	@@java -jar build/yuicompressor-2.4.6.jar --type css ${OUTPUT}/${CSSSTRUCTURE} >> ${OUTPUT}/${CSSSTRUCTUREMIN}

# Build the normal JS file
js: init
	# Build the JavaScript file
	@@head -8 js/jquery.mobile.core.js | ${SED_VER} > ${OUTPUT}/${JS}
	@@cat ${JSFILES} >> ${OUTPUT}/${JS}

# Create the output directory. This is in a separate step so its not dependant on other targets
init:
	# Building jQuery Mobile in the "${OUTPUT}" folder
	@@rm -rf ${OUTPUT}
	@@mkdir ${OUTPUT}

# Build the minified JS file
min: init js
	# Build the minified JavaScript file
	@@echo ${MIN_VER} | ${SED_VER} > ${OUTPUT}/${MIN}
	@@java -jar build/google-compiler-20111003.jar --js ${OUTPUT}/${JS} --warning_level QUIET --js_output_file ${MIN}.tmp
	@@cat ${MIN}.tmp >> ${OUTPUT}/${MIN}
	@@rm -f ${MIN}.tmp

# Let the user know the files were built and where they are
notify:
	@@echo "The files have been built and are in: " $$(pwd)/${OUTPUT}

# Pull the latest commits. This is used for the nightly build but can be used to save some keystrokes
pull:
	@@git pull --quiet

# Zip the 4 files and the theme images into one convenient package
zip: init js min css cssmin
	@@mkdir -p ${DIR}
	@@cp ${OUTPUT}/*.js ${DIR}/
	@@cp ${OUTPUT}/*.css ${DIR}/
	@@cp -R css/themes/${CSSTHEME}/images ${DIR}/
	@@zip -rq ${OUTPUT}/${DIR}.zip ${DIR}
	@@rm -fr ${DIR}


# Used by the jQuery team to make the nightly builds
nightly: pull zip
	# Create the folder to hold the files for the demos
	@@mkdir -p ${VER}

	# Copy in the base stuff for the demos
	@@cp -r index.html css experiments docs tools ${VER}/

	# First change all the paths from super deep to the same level for JS files
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|src="../../../js|src="js|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|src="../../js|src="js|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|src="../js|src="js|g' {} \;

	# Then change all the paths from super deep to the same level for CSS files
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|media="only all"||g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|rel="stylesheet"  href="../../../|rel="stylesheet"  href="|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|rel="stylesheet"  href="../../|rel="stylesheet"  href="|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|rel="stylesheet"  href="../|rel="stylesheet"  href="|g' {} \;

	# Change the empty paths to the location of this nightly file
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|href="css/themes/${CSSTHME}/"|href="${NIGHTLY_WEBPATH}/${DIR}.min.css"|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|src="js/jquery.js"|src="http://code.jquery.com/jquery-${JQUERY}.min.js"|' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i 's|src="js/"|src="${NIGHTLY_WEBPATH}/${DIR}.min.js"|g' {} \;

	# Move the demos into the output folder
	@@mv ${VER} ${OUTPUT}/demos

	# Copy the images as well
	@@cp -R css/themes/${CSSTHME}/images ${OUTPUT}

	@@${RMLATEST}
	@@scp -r ${OUTPUT} jqadmin@code.origin.jquery.com:/var/www/html/code.jquery.com/mobile/${NIGHTLY_OUTPUT}
	@@rm -rf ${OUTPUT}

# Used by the jQuery team to deploy a build to the CDN
deploy: zip
	# Deploy to CDN
	@@mv ${OUTPUT} ${VER}
	@@scp -r ${VER} jqadmin@code.origin.jquery.com:/var/www/html/code.jquery.com/mobile/
	@@mv ${VER} ${OUTPUT}

	# Deploy Demos to the jQueryMobile.com site
	@@mkdir -p ${VER}
	@@cp -r index.html css experiments docs tools ${VER}/

	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|src="../../../js|src="js|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|src="../../js|src="js|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|src="../js|src="js|g' {} \;

	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|media="only all"||g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|rel="stylesheet"  href="../../../|rel="stylesheet"  href="|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|rel="stylesheet"  href="../../|rel="stylesheet"  href="|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|rel="stylesheet"  href="../|rel="stylesheet"  href="|g' {} \;

	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|href="css/themes/${CSSTHEME}/"|href="http://code.jquery.com/mobile/${VER}/${DIR}.min.css"|g' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|src="js/jquery.js"|src="http://code.jquery.com/jquery-${JQUERY}.min.js"|' {} \;
	@@find ${VER} -type f -name '*.html' -exec sed -i "" -e 's|src="js/"|src="http://code.jquery.com/mobile/${VER}/${DIR}.min.js"|g' {} \;

	@@scp -r ${VER} jqadmin@jquerymobile.com:/srv/jquerymobile.com/htdocs/demos/

	# Clean up the local files
	@@rm -rf ${VER}
	@@echo "All Done"
