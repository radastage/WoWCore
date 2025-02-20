        ��  ��                  �  @   ��
 I W _ J S _ T A B C O N T R O L         0	        function hasSupport() 
{
	if (typeof hasSupport.support != "undefined")
		return hasSupport.support;
	
	var ie55 = /msie 5\.[56789]/i.test( navigator.userAgent );
	
	hasSupport.support = ( typeof document.implementation != "undefined" &&
			document.implementation.hasFeature( "html", "1.0" ) || ie55 )
			
	// IE55 has a serious DOM1 bug... Patch it!
	if ( ie55 ) {
		document._getElementsByTagName = document.getElementsByTagName;
		document.getElementsByTagName = function ( sTagName ) {
			if ( sTagName == "*" )
				return document.all;
			else
				return document._getElementsByTagName( sTagName );
		};
	}

	return hasSupport.support;
}

function JSTabControl( el) {
	if ( !hasSupport() || el == null ) return;
	
	this.element = el;
	this.element.tabPane = this;
	this.pages = [];
	this.selectedIndex = null;
	
	var tabIndex = 0;
	this.selectedIndex = tabIndex;
	this.SubmitOnChange = false;
    this.SubmitOnAsync = false;
}

JSTabControl.prototype.classNameTag = "tab-control";

JSTabControl.prototype.setSelectedIndex = function ( n ) {
	if (this.selectedIndex != n) {
		if (this.selectedIndex != null && this.pages[ this.selectedIndex ] != null )
			this.pages[ this.selectedIndex ].hide();
		this.selectedIndex = n;
		this.pages[ this.selectedIndex ].show();
	}

	//persist selected index so at to be posted to the server on submits
	IWTop().FindElem( this.element.id + "_input").value = n;

	if( this.SubmitOnChange ) {
		SubmitClick(this.element.id,'', false);
	}
	//This is actually mapped to OnAsyncChange
    if(this.SubmitOnAsync) {
      executeAjaxEvent("&page=" + n, this.element.id + 'IWCL', this.element.id + '.DoOnAsyncChange', true);
    }
};

JSTabControl.prototype.getSelectedIndex = function () {
	return this.selectedIndex;
};

JSTabControl.prototype.addTabPage = function ( oElement, ATabTitleID ) {
	if ( !hasSupport() ) return;

	if ( oElement.tabPage == this )	// already added
		return oElement.tabPage;

	var n = this.pages.length;
	var tp = this.pages[n] = new JSTabPage( oElement, this, n, ATabTitleID );
		
	if ( n == this.selectedIndex )
		tp.show();
	else
		tp.hide();
		
	return tp;
};


JSTabControl.prototype.dispose = function () {
	this.element.tabPane = null;
	this.element = null;		
	this.tabRow = null;
	
	for (var i = 0; i < this.pages.length; i++) {
		this.pages[i].dispose();
		this.pages[i] = null;
	}
	this.pages = null;
};


function JSTabPage( el, tabPane, nIndex, ATabTitleID ) {
	if ( !hasSupport() || el == null ) return;
	
	this.tabPane = tabPane;
	this.element = el;
	this.element.tabPage = this;
	this.index = nIndex;

	this.tab = document.getElementById(ATabTitleID);

	// hook up events, using DOM0
	var oThis = this;
	this.tab.onclick = function () { oThis.select(); };
}
	
JSTabPage.prototype.show = function () {
	var titleElem = this.tab;
	var styleHolder = document.getElementById(  "STYLEHOLDER_"  + this.tabPane.element.id + "_ACTIVE" );
	
	titleElem.style.cssText = styleHolder.style.cssText;
	
	this.element.style.display = "block";
};

JSTabPage.prototype.hide = function () {
	var titleElem = this.tab;
	var styleHolder = document.getElementById(  "STYLEHOLDER_"  + this.tabPane.element.id + "_INACTIVE" );
	
	titleElem.style.cssText = styleHolder.style.cssText;

	this.element.style.display = "none";
};	
	
	
JSTabPage.prototype.select = function () {
	this.tabPane.setSelectedIndex( this.index );
};  