class Quest2StudentService
  class << self
    # @return [String]
    def all_agents
      Agent.pluck(:codename).join("\n")
    end

    # @return [String]
    def all_missions
      Mission.order(title: :asc).pluck(:title).join("\n")
    end

    # @return [String]
    def agents_with_missions
      agents = Agent.includes(:missions).order(:codename)
      agents.map do |agent|
        mission_titles = agent.missions.pluck(:title).sort.join(", ")
        "#{agent.codename}: #{mission_titles}"
      end.join("\n")
    end

    # @return [String]
    def agents_with_missions_sorted_by_mission_count
      agents = Agent.includes(:missions).all
      sorted_agents = agents.sort_by do |agent|
        [ -agent.missions.length, agent.codename ]
      end

      sorted_agents.map do |agent|
        mission_count = agent.missions.length
        mission_titles = agent.missions.pluck(:title).sort.join(", ")

        "#{agent.codename} (#{mission_count}): #{mission_titles}"
      end.join("\n")
    end

    # @return [String]
    def agents_with_skills
      agent = Agent.includes(:skills)

      agent.map do |agent|
        skilles = agent.skills.pluck(:name).sort.join(", ")
        "#{agent.codename}: #{skilles}"
      end.join("\n")
    end

    # @return [String]
    def skills_by_agent_count
      skill = Skill.includes(:agents)
      sorted_skills = skill.sort_by do |skill|
        [ -skill.agents.length, skill.name ]
      end

      sorted_skills.map do |skill|
        agent_count = skill.agents.length
        agents = skill.agents.pluck(:codename).sort.join(", ")

        "#{skill.name} (#{agent_count}): #{agents}"
      end.join("\n")
    end
  end
end
