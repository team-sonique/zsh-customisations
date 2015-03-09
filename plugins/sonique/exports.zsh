export TOOLS=~/tools
export M2_HOME=$TOOLS/mvn
export ACTIVEMQ_HOME=$TOOLS/apache-activemq-5.10.1
export ANT_HOME=$TOOLS/apache-ant-1.8.2
export JRUBY_HOME=$TOOLS/jruby
export PHANTOMJS_HOME=$TOOLS/phantomjs/phantomjs-2.0.0-macosx
export FIREFOX_HOME=/Applications/Firefox.app/Contents/MacOS/

export MAVEN2_VER=2.2.1
export MAVEN3_VER=3.2.2

export SVN_EDITOR=vim
export VIMINIT='source ${ZDOTDIR}/exrc'
export CDPATH=.:~/projects:~/trunk/netstream

export PATH=.:$M2_HOME/bin:$ACTIVEMQ_HOME/bin:$JRUBY_HOME/bin:$ANT_HOME/bin:$PHANTOMJS_HOME/bin:$FIREFOX_HOME:$PATH
