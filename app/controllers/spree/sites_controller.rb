module Spree
    class SitesController< BaseController
      def new
        if request.get?
          @site = Spree::Site.new
          @user = @site.users.build
        else
          @site = Spree::Site.new(params[:site])
          @user = Spree::User.new(params[:user])
          @site.users << @user
          if @site.save
            @site.users.first.roles << Role.create(:name => "admin") 
            # should not add  @site.name as suffix of role.name, User.admin require :name="admin"
            if @site.has_sample?
              @site.update_attributes!(:loading_sample=>true)
              # add job to load sample
              Delayed::Job.enqueue SampleSeedJob.new( @site )
            end 
            redirect_to site_path(@site)
          end
        end
      end
      
      def show
        @site = Spree::Site.find(params[:id])
        render :after_new
      end
           
    end
  
end