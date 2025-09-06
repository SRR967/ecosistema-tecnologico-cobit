interface TeamMember {
  name: string;
}

interface TeamCardProps {
  institution: string;
  members: TeamMember[];
  director: string;
  className?: string;
}

export default function TeamCard({
  institution,
  members,
  director,
  className = "",
}: TeamCardProps) {
  return (
    <div
      className={`bg-white rounded-lg shadow-lg border border-gray-200 p-6 space-y-6 ${className}`}
    >
      {/* Institución */}
      <div>
        <h3
          className="text-xl font-bold mb-2"
          style={{ color: "var(--cobit-blue)" }}
        >
          Institución
        </h3>
        <p className="text-gray-700 b1">{institution}</p>
      </div>

      {/* Integrantes */}
      <div>
        <h3
          className="text-xl font-bold mb-3"
          style={{ color: "var(--cobit-blue)" }}
        >
          Integrantes
        </h3>
        <ul className="space-y-2">
          {members.map((member, index) => (
            <li key={index} className="text-gray-700 b1 flex items-center">
              <span
                className="w-2 h-2 rounded-full mr-3"
                style={{ backgroundColor: "var(--cobit-red)" }}
              ></span>
              {member.name}
            </li>
          ))}
        </ul>
      </div>

      {/* Director */}
      <div>
        <h3
          className="text-xl font-bold mb-2"
          style={{ color: "var(--cobit-blue)" }}
        >
          Director
        </h3>
        <p className="text-gray-700 b1">{director}</p>
      </div>
    </div>
  );
}
