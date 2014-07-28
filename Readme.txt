=============================
AI Lovers スターターパッケージ
=============================

このスターターパッケージは、AI Loversを自分のマシンで実行し、AIを開発するためのパッケージです。
自分だけの最強AIを開発したら、オンライン対戦サーバー(http://arena.ai-comp.net/)にAIを投稿して、他のプレイヤーと対戦しましょう！

-----------------------------
実行方法
-----------------------------

実行にはJava1.6以降が必要です。

スターターパッケージのディレクトリでコンソールを開き、以下のコマンドでAI Loversを実行すると、サンプルAIプログラム同士の対戦が行われます。
対戦のログはコンソールに出力されるほか、スターターパッケージディレクトリ下のlog.txtにも出力されます。

    java -jar AILovers.jar

自分のAIを対戦させるには、以下のように-aオプションでAIプログラムの実行コマンドを指定します。-wオプションでワーキングディレクトリを指定できます。

    java -jar AILovers.jar -a "java SampleAI" -w "./SampleAI/Java"

AIプログラムおよびワーキングディレクトリはそれぞれ4つまで指定できます。

    java -jar AILovers.jar -a "java SampleAI" -w "./SampleAI/Java" -a "python SampleAI.py" -w "./SampleAI/Python2"

その他のオプションについては以下のコマンドで表示されるヘルプをご参照ください。

    java -jar AILovers.jar -h
	
-----------------------------
サンプルプログラム
-----------------------------

SampleAIディレクトリにサンプルプログラムが入っています。AIを作成する際の参考にしてください。
AIの入出力形式についてはゲームルールをご参照ください。
http://www.ai-comp.net/cedec2014/#game-rules

なお、サンプルプログラムと同梱のcompile.shおよびrun.shはオンライン対戦サーバーで投稿する際に使用するスクリプトです。
詳しくはオンライン対戦サーバーのヘルプをご参照ください。

-----------------------------
Webサイト
-----------------------------

ゲームルール
http://www.ai-comp.net/cedec2014/#game-rules

オンライン対戦サーバー
http://arena.ai-comp.net/

公式Webサイト
http://www.ai-comp.net/cedec2014/

CEDECセッション情報
http://cedec.cesa.or.jp/2014/session/ENG/13108.html
