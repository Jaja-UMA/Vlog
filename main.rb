# coding: utf-8
require "digest/md5"
require "active_record"
require "sinatra"
require "cgi/escape"
require "json"

set :environment, :production
set :sessions,
    expire_after: 7200,
    secret: 'abcdefghij0123456789'


ActiveRecord::Base.configurations = YAML.load_file("database.yml")
ActiveRecord::Base.establish_connection :development

class Account < ActiveRecord::Base
end

class Book < ActiveRecord::Base
end

#最初のページ
#ログイン，登録を促す
get '/' do
  erb :index
end

#ログイン用ページ
get '/login' do
  @message=$message
  erb :login
end

#ログアウト用ページ
post '/logout' do
  session.clear
  redirect '/'
end

#コンテンツ一覧紹介ページ
get '/contents' do
  if (session[:login_flag] == true)
    time=Time.now
    @year=time.strftime("%Y")
    @mon=time.strftime("%m")
    erb :contents
  else
    erb :badrequest
  end
end

#みんなの家計簿の表示
get '/contents/EveryOne' do
  if(session[:login_flag] == true)
    @sishutu=0
    @shunyuu=0
    time=Time.now
    @strtime=time.strftime("%Y-%m-%d")

    @a=Book.all
    @a.each do |book|
      tmpdate=book.dateofuse
      if (tmpdate.to_s ==@strtime && book.sishu =="Income")
        @shunyuu=@shunyuu+(book.howmuch)
      elsif (tmpdate.to_s == @strtime && book.sishu =="Spend" )
        @sishutu=@sishutu+(book.howmuch)
      end
    end
    erb :EveryOne
  else
    erb :badrequest
  end
end

#月ごとの自分の家計簿を表示
get '/contents/Yours/:year/:mon' do
  if(session[:login_flag]==true)
    year=params[:year]
    mon=params[:mon]
    if mon=="12"
      tmpnxyear=year.to_i+1
      @nxyear=tmpnxyear.to_s
      @nxmon="1"
      @bcmon=mon.to_i-1
      @bcyear=year
    elsif mon=="1"
      @bcyear=year.to_i-1
      @bcmon="12"
      @nxyear=year
      @nxmon=mon.to_i+1
    else
      tmpmon=mon.to_i+1
      @nxmon=tmpmon.to_s
      @nxyear=year
      @bcmon=mon.to_i-1
      @bcyear=year
    end
    @a=Book.all
    time=Time.now
    @strtime=time.strftime("%Y-%m")
    @strtime=year.to_s+'-'+mon.to_s
    @sishutu=0
    @shunyuu=0

    @a.each do |book|
      tmpdate=book.dateofuse.to_s
      date=tmpdate.slice(0..6)
      if (date == @strtime && book.sishu =="Income" && book.idforbook==session[:username])
        @shunyuu=@shunyuu+(book.howmuch)
      elsif (date == @strtime && book.sishu =="Spend" && book.idforbook==session[:username])
        @sishutu=@sishutu+(book.howmuch)
      end
    end
    erb :yours
  else
    erb :badrequest
  end

end

#家計簿登録ページ
get '/contents/RegiMoney' do
  if(session[:login_flag] == true)
    a=Book.all
    @num=a.count+1
    erb :RegiMoney
  else
    erb :badrequest
  end
end

#家計簿登録認証メゾット
post '/contents/RegiMoney/:uname/:num/auth' do
  if(session[:login_flag] == true)
    if params[:check]=="NoProblem"
      a=Book.new
      a.number=params[:num]
      a.howmuch=params[:money].to_i
      a.idforbook=params[:uname]
      a.sishu=params[:OR]
      a.dateofuse=params[:DateOfUseMoney]
      if(params[:contents].empty?)
        a.contents="無記入"
      else
        a.contents=params[:contents]
      end
      a.save
      redirect '/contents'
    else
      erb :badrequest
    end
  else
    erb :badrequest
  end
end

#アカウント登録用ページ
get '/register' do
  erb :regi
end

#jsを適用する上で作成
#valには/registerのユーザーネームフォームの文字列が入る
get '/register/:val' do
  #フォーム内容をサニタイズしてidに格納
  id = CGI.escapeHTML(params[:val])
  #idとマッチするものをデータベースから検索
  #あればlには1，なければ0になる
  a = Account.where("id = ?", "#{id}")
  l=a.length
  #jsに送信
  l.to_json
end

post '/RegiAuth' do

  pass=CGI.escapeHTML(params[:pass])
  uname=CGI.escapeHTML(params[:Uname])

  salt =SecureRandom.base64(20);
  hashed=Digest::MD5.hexdigest(salt+pass)
  algorithm="1"

  a=Account.new
  a.id=uname
  a.salt=salt
  a.hashed=hashed
  a.algo=algorithm
  a.save

  redirect '/compregi'
end

get '/compregi' do
  erb :comp
end

#ログイン認証メゾット
post '/auth' do
  uname=CGI.escapeHTML(params[:uname])
  pass=CGI.escapeHTML(params[:pass])
  begin
    a=Account.find(uname)
    db_username=a.id
    db_salt=a.salt
    db_hashed=a.hashed
    db_algo=a.algo
  rescue=>e
    puts "User #{uname} is not found."
    $message="存在しないユーザーネームです"
    redirect '/login'
  end
  trial_hashed=Digest::MD5.hexdigest(db_salt+pass)

  if((uname==db_username)&&(db_hashed==trial_hashed))
    session[:login_flag] = true
    session[:username] = db_username
    redirect "/contents"
  else
    session[:login_flag]= false
    redirect '/failure'
  end

end

def easysee(str)
  i=0
  tmp=str
  while i<tmp.length
    if i%4==0
      first=str.length-i-1
      enf=first+1
      if i==4
        str =str.slice(0..first) +"万" + str.slice(enf..str.length)
      elsif i==8
        str =str.slice(0..first-1) +"億" + str.slice(enf-1..str.length)
        break
      end
    end
    i+=1
  end
  return str
end
