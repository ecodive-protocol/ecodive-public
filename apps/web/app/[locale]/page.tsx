import { Navbar } from "@/components/Navbar";
import { Hero } from "@/components/Hero";
import { Tokenomics } from "@/components/Tokenomics";
import { Roadmap } from "@/components/Roadmap";
import { FAQ } from "@/components/FAQ";
import { Newsletter } from "@/components/Newsletter";
import { Footer } from "@/components/Footer";

export default function Home() {
  return (
    <div className="bg-black min-h-screen">
      <Navbar />
      <Hero />
      <Tokenomics />
      <Roadmap />
      <FAQ />
      <Newsletter />
      <Footer />
    </div>
  );
}
