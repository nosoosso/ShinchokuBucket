# ShinchokuBucket

### これは何

Bitbucketより一週間以内にresolvedとされたissueを取得し、Slackに投稿するBOTです。

![shinchoku](http://cdn-ak.f.st-hatena.com/images/fotolife/n/nosoosso/20150613/20150613003945.png)

### 設定

conf.ymlに必要な情報を記述します。全て必須項目です。

- consumer_key
- secret_key

BitbucketよりOAuth認証に必要なそれぞれのキーを入力します。

- team

リポジトリを所有しているチーム名、あるいはユーザー名を入力します。

- repossitory

リポジトリ名を入力します。

- incoming_webhook_url

Slackに投稿するためのURLを入力します。

### 使い方

全ての項目が入力できれば、スクリプトを実行してください。  
入力項目に間違いがなければ、Slackに1週間の進捗が投稿されます。

