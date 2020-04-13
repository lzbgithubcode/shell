module Fastlane
  module Actions
    module SharedValues
      GIT_REMOVE_TAG_CUSTOM_VALUE = :GIT_REMOVE_TAG_CUSTOM_VALUE
    end

    class GitRemoveTagAction < Action
      def self.run(params)
      #执行逻辑
      tagName = params[:tag]
      isRemoveLocationTag = params[:rLocation]
      isRemoveRemoteTag = params[:rRomote]
      
      #1.定义一个命令数组
      cmds = []
      
      #2.把命令增加到数组里面去
      if isRemoveLocationTag
         cmds << " git tag -d #{tagName} "
      end
    
      if isRemoveRemoteTag
        cmds << " git push origin :#{tagName}"
      end
      
      #3.执行数组里面的名称
      result = Action.sh(cmds.join('&'));
      return result
      end
      
      #删除本地tag  git tag -d 标签
      
      #删除远程tags  git push origin :标签

      end
      def self.description
          "删除本地或者远程tag"
      end

      def self.details
         "action的功能描述：我们可以使用这个标签来删除git远程的标签\n 使用方式是：\n git_remove_tag(tag:tagName,rLocation:true,isRemoveRemoteTag:true) \n或者 \ngit_remove_tag(tag:tagName)"
      end

      def self.available_options
       #接收参数
        [
          FastlaneCore::ConfigItem.new(key: :tag,
                                       description: "被删除的标签名称",
                                       optional: false,
                                       is_string: true),
         FastlaneCore::ConfigItem.new(key: :isRemoveRemoteTag,
                                      description: "是否删除的远程标签",
                                      optional: true,
                                      is_string: false,
                                      default_value: true),
          FastlaneCore::ConfigItem.new(key: :rLocation,
                                       description: "是否删除的本地标签",
                                       optional: true,
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['GIT_REMOVE_TAG_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["lzb"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
  end
end
