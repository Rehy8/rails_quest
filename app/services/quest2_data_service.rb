class Quest2DataService
  TASKS = [
    {
      step: 1,
      key: :all_agents,
      title: {
        ru: "Список всех агентов",
        en: "List all agents"
      },
      description: {
        ru: "Запусти сиды и выведи список всех агентов из оперативной базы.",
        en: "Run seeds and print the list of all agents from the operational database."
      },
      command: 'bin/rails db:seed && bin/rails runner "puts Quest2DataService.all_agents"',
      expected_output: <<~TEXT.strip
        Atlas
        Echo
        Nova
        Viper
      TEXT
    },
    {
      step: 2,
      key: :all_missions,
      title: {
        ru: "Список всех миссий",
        en: "List all missions"
      },
      description: {
        ru: "Выведи список всех миссий в алфавитном порядке.",
        en: "Print the full mission list in alphabetical order."
      },
      command: 'bin/rails runner "puts Quest2DataService.all_missions"',
      expected_output: <<~TEXT.strip
        Ember Trace
        Frozen Cipher
        Ghost Signal
        Glass Horizon
        Harbor Shield
        Iron Veil
        Midnight Relay
        Sapphire Run
        Silent Echo
        Solar Tide
      TEXT
    },
    {
      step: 3,
      key: :agents_with_missions,
      title: {
        ru: "Агенты и их миссии",
        en: "Agents and their missions"
      },
      description: {
        ru: "Покажи каждому агенту его миссии.",
        en: "Show each agent together with their missions."
      },
      command: 'bin/rails runner "puts Quest2DataService.agents_with_missions"',
      expected_output: <<~TEXT.strip
        Atlas: Harbor Shield, Midnight Relay, Silent Echo
        Echo: Ghost Signal, Iron Veil, Sapphire Run, Solar Tide
        Nova: Frozen Cipher
        Viper: Ember Trace, Glass Horizon
      TEXT
    },
    {
      step: 4,
      key: :agents_with_missions_sorted_by_mission_count,
      title: {
        ru: "Агенты и миссии по убыванию числа миссий",
        en: "Agents and missions by mission count"
      },
      description: {
        ru: "Отсортируй агентов по убыванию числа миссий и выведи их списки.",
        en: "Sort agents by mission count descending and print their mission lists."
      },
      command: 'bin/rails runner "puts Quest2DataService.agents_with_missions_sorted_by_mission_count"',
      expected_output: <<~TEXT.strip
        Echo (4): Ghost Signal, Iron Veil, Sapphire Run, Solar Tide
        Atlas (3): Harbor Shield, Midnight Relay, Silent Echo
        Viper (2): Ember Trace, Glass Horizon
        Nova (1): Frozen Cipher
      TEXT
    },
    {
      step: 5,
      key: :agents_with_skills,
      title: {
        ru: "Агенты и их навыки",
        en: "Agents and their skills"
      },
      description: {
        ru: "Выведи список агентов и навыки каждого из них.",
        en: "Print agents together with all of their skills."
      },
      command: 'bin/rails runner "puts Quest2DataService.agents_with_skills"',
      expected_output: <<~TEXT.strip
        Atlas: Cryptography, Recon
        Echo: Field Medicine, Infiltration, Recon
        Nova: Cryptography, Negotiation
        Viper: Infiltration, Negotiation, Recon
      TEXT
    },
    {
      step: 6,
      key: :skills_by_agent_count,
      title: {
        ru: "Навыки и количество агентов",
        en: "Skills and agent counts"
      },
      description: {
        ru: "Сгруппируй навыки по количеству агентов и покажи, кто ими владеет.",
        en: "Group skills by agent count and show which agents possess them."
      },
      command: 'bin/rails runner "puts Quest2DataService.skills_by_agent_count"',
      expected_output: <<~TEXT.strip
        Recon (3): Atlas, Echo, Viper
        Cryptography (2): Atlas, Nova
        Infiltration (2): Echo, Viper
        Negotiation (2): Nova, Viper
        Field Medicine (1): Echo
      TEXT
    }
  ].freeze

  class << self
    def tasks
      TASKS
    end

    def output_for(key)
      public_send(key)
    rescue StandardError
      ""
    end

    def all_agents
      safely do
        agent_scope.order(:codename).pluck(:codename).join("\n")
      end
    end

    def all_missions
      safely do
        mission_scope.order(:title).pluck(:title).join("\n")
      end
    end

    def agents_with_missions
      safely do
        agent_scope.includes(:missions).order(:codename).map do |agent|
          "#{agent.codename}: #{names_for(agent.missions).join(', ')}"
        end.join("\n")
      end
    end

    def agents_with_missions_sorted_by_mission_count
      safely do
        agent_scope.includes(:missions).to_a
          .sort_by { |agent| [ -agent.missions.size, agent.codename ] }
          .map do |agent|
            "#{agent.codename} (#{agent.missions.size}): #{names_for(agent.missions).join(', ')}"
          end
          .join("\n")
      end
    end

    def agents_with_skills
      safely do
        agent_scope.includes(:skills).order(:codename).map do |agent|
          "#{agent.codename}: #{names_for(agent.skills, attribute: :name).join(', ')}"
        end.join("\n")
      end
    end

    def skills_by_agent_count
      safely do
        skill_scope.includes(:agents).to_a
          .sort_by { |skill| [ -skill.agents.size, skill.name ] }
          .map do |skill|
            "#{skill.name} (#{skill.agents.size}): #{names_for(skill.agents).join(', ')}"
          end
          .join("\n")
      end
    end

    private

    def safely
      return "" unless agents_ready?

      yield.to_s
    rescue StandardError
      ""
    end

    def names_for(records, attribute: :title)
      records.to_a.sort_by { |record| record.public_send(attribute) }.map { |record| record.public_send(attribute) }
    end

    def agent_scope
      agent_class.all
    end

    def mission_scope
      raise ActiveRecord::StatementInvalid unless model_ready?(mission_class, :missions)

      mission_class.all
    end

    def skill_scope
      raise ActiveRecord::StatementInvalid unless model_ready?(skill_class, :skills)

      skill_class.all
    end

    def agents_ready?
      model_ready?(agent_class, :agents)
    end

    def model_ready?(klass, table_name)
      klass.present? && ActiveRecord::Base.connection.data_source_exists?(table_name)
    rescue StandardError
      false
    end

    def agent_class
      @agent_class ||= "Agent".safe_constantize
    end

    def mission_class
      @mission_class ||= "Mission".safe_constantize
    end

    def skill_class
      @skill_class ||= "Skill".safe_constantize
    end
  end
end
