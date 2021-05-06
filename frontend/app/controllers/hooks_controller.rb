class HooksController < ActionController::Base
  def receive
    if request.headers['Content-Type'] == 'application/json'
      data = JSON.parse(request.body.read)
    else
      # application/x-www-form-urlencoded
      data = params.as_json
    end

    %x( git pull --rebase --autostash )
    %x( pkill -USR2 ruby )

    head :ok
  end
end
