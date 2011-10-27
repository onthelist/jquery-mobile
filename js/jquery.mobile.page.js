/*
* jQuery Mobile Framework : "page" plugin
* Copyright (c) jQuery Project
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*/

(function( $, undefined ) {

$.widget( "mobile.page", $.mobile.widget, {
	options: {
		backBtnText: "Back",
		addBackBtn: false,
		backBtnTheme: null,
		degradeInputs: {
			color: false,
			date: true,
			datetime: true,
			"datetime-local": true,
			email: false,
			month: false,
			number: false,
			range: "number",
			search: true,
			tel: false,
			time: false,
			url: false,
			week: false
		},
		keepNative: null,
		theme: "c",
		domCache: false,
		keepNativeDefault: ":jqmData(role='none'), :jqmData(role='nojs')"
	},

	_create: function() {

		this._trigger( "beforecreate" );

		this.element
			.attr( "tabindex", "0" )
			.addClass( "ui-page ui-body-" + this.options.theme );
	},

	keepNativeSelector: function() {
		var options = this.options,
			keepNativeDefined = options.keepNative && $.trim(options.keepNative);

		if( keepNativeDefined && options.keepNative !== options.keepNativeDefault ){
			return [options.keepNative, options.keepNativeDefault].join(", ");
		}

		return options.keepNativeDefault;
	}
});
})( jQuery );
