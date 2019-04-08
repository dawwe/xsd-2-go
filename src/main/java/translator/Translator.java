package translator;

import parser.Parse;
import loader.Loader;
import java.util.Set;



public class Translator {

    String classDir;
    String classPkg;

    Loader loader;
    Parse parser;

    public Translator(String dir, String pkg) {
        this.classDir = dir;
        this.classPkg = pkg;
        this.loader = new Loader(this.classDir);
        this.parser = new Parse(this.loader, this.classPkg);
        this.parser.init();
    }

    public String go(String classFullName) throws ClassNotFoundException {
        return parser.parse(loader.load(classFullName));
    }

    public String allEnums() {
        StringBuilder buffer = new StringBuilder();
        Set<String> enums = loader.getEnumClassTable();
        for (String e : enums) {
            buffer.append(String.format("type %s string\n", e));
        }
        return buffer.toString();
    }
}
