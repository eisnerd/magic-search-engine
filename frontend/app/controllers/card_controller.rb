class CardController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    if @card
      @title = @card.name
    else
      render_404
    end
  end

  def gallery
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end

    if @card
      first_printing = @card.printings.first
      if @card == first_printing
        @title = @card.name
        page = [1, params[:page].to_i].max
        @total_printings = @card.printings.size
        @printings = paginate_by_set(@card.printings, page)
      else
        redirect_to set: first_printing.set_code, id: first_printing.number
      end
    else
      render_404
    end
  end

  # Logic tested in CLIFrontend, probably should be moved to database
  # as this untested copypasta is nasty
  # FIXME: And now it's not even the same anymore
  def index
    @_pool = params[:pool]
    @_pools = params[:pools] || ""
    @_format = params[:format]
    @__formats = (params[:formats] || 0).to_i
    @_sort = params[:sort]
    @_sorting_order = (params[:sorting_order] || 0).to_i
    @search = (params[:q] || "").strip
    page = [1, params[:page].to_i].max

    filters = ""
    if @_pool
      filters << " (pool:\"#{@_pools}\") "
    end
    if @_format
      filters << " (format:\"#{formats[@__formats - 1].name}\") "
    end
    if @_sort
      sorting_order = sorting_orders[@_sorting_order - 1]
      filters << " (sort:\"#{sorting_order.value}\") "
    end

    unless @search.present? || filters.present?
      @empty_page = true
      @cards = []
      return
    end

    # Temporary issue with bots
    if params[:page]
      logger.info "PAGINATED #{params.inspect} BY USERAGENT: #{request.headers['HTTP_USER_AGENT']}"
    end

    if request.headers['HTTP_USER_AGENT'] =~ /MJ12bot/ and params[:page]
      render_403
      return
    end

    # End of temporary bot code

    @title = @search
    query = Query.new(@search + filters, params[:random_seed])
    @seed = query.seed
    results = $CardDatabase.search(query)
    print results.card_names
    @warnings = results.warnings
    @cards = results.card_groups.map do |printings|
      choose_best_printing(printings)
    end

    case query.view
    when "full"
      # force detailed view
      @cards = @cards.paginate(page: page, per_page: 10)
      render "index_full"
    when "images"
      @cards = @cards.paginate(page: page, per_page: 60)
      render "index_images"
    when "text"
      @cards = @cards.paginate(page: page, per_page: 60)
      render "index_text"
    when "checklist"
      @cards = @cards.paginate(page: page, per_page: 500)
      render "index_checklist"
    when "short"
      # default view
      @cards = @cards.paginate(page: page, per_page: 25)
    else
      @cards = @cards.paginate(page: page, per_page: 99)
      render "index_images"
    end
  end

  private

  def choose_best_printing(printings)
    best_printing = printings.find{|cp| ApplicationHelper.card_picture_path(cp) } || printings[0]
    [best_printing, printings]
  end
end
