interface LogoProps {
  text?: string;
  className?: string;
}

export default function Logo({
  text = "COBIT 2019",
  className = "",
}: LogoProps) {
  return (
    <div className={`text-cobit-red font-bold text-xl ${className}`}>
      {text}
    </div>
  );
}
