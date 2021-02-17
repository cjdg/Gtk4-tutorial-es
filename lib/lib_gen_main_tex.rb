# lib_gen_main_tex.rb
#  -- Library ruby script to generate main.tex.

def gen_main_tex directory, texfilenames, appendixfilenames
  #  parameter: directory: the destination directory to put generated files.
  #             texfilenames: an array of latex files. Each of them is "secXX.tex" where XX is digits.   

  # ------ Generate helper.tex ------
  # Get preamble from a latex file generated by pandoc.
  #  1. Generate sample latex file by `pandoc -s -o sample.tex sample.md`
  #  2. Extract the preamble of sample.tex.
  #  3. Add geometry package.

sample_md = <<'EOS'
# title

line1

~~~C
int main(int argc, char **argv) {
}
~~~
EOS

  File.write "sample.md", sample_md
  if (! system("pandoc", "-s", "-o", "sample.tex", "sample.md"))
    raise ("pandoc retuns error status #{$?}.\n")
  end
  sample_tex = File.read("sample.tex")
  sample_tex.gsub!(/\\documentclass\[[^\]]*\]{[^}]*}/,"")
  sample_tex.gsub!(/\\usepackage\[[^\]]*\]{geometry}/,"")
  sample_tex.gsub!(/\\usepackage\[[^\]]*\]{graphicx}/,"")
  sample_tex.gsub!(/\\setcounter{secnumdepth}{-\\maxdimen} % remove section numbering/,"")
  sample_tex.gsub!(/\\author{[^}]*}/,"")
  sample_tex.gsub!(/\\date{[^}]*}/,"")
  preamble = []
  sample_tex.each_line do |l|
    if l =~ /\\begin{document}/
      break
    elsif l != "\n"
      preamble << l
    end
  end
  preamble << "\\usepackage[margin=2.4cm]{geometry}\n"
  preamble << "\\usepackage{graphicx}\n"
  File.write("#{directory}/helper.tex",preamble.join)
  File.delete("sample.md")
  File.delete("sample.tex")

  # ------ Generate main.tex ------

main = <<'EOS'
\documentclass[a4paper]{article}
\include{helper.tex}
\title{Gtk4 tutorial for beginners}
\author{Toshio Sekiya}
\date{}
\begin{document}
\maketitle
\begin{abstract}
\input{abstract.tex}
\end{abstract}
\newpage
\tableofcontents
\newpage
EOS

  texfilenames.each do |filename|
    main += "  \\input{#{filename}}\n"
  end
  main += "\\newpage\n"
  main += "\\appendix\n"
  appendixfilenames.each do |filename|
    main += "  \\input{#{filename}}\n"
  end
  main += "\\end{document}\n"
  IO.write("#{directory}/main.tex", main)
end