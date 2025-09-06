import Image from "next/image";
import NavBar from "../components/organisms/NavBar";

export default function Home() {
  return (
    <div className="min-h-screen">
      <NavBar currentPath="/" />
    </div>
  );
}
