package org.kframework.compile.transformers;


import org.kframework.compile.utils.MetaK;
import org.kframework.kil.*;
import org.kframework.kil.visitors.CopyOnWriteTransformer;
import org.kframework.kil.visitors.exceptions.TransformerException;

import java.util.Set;

public class ResolveSyntaxPredicates extends CopyOnWriteTransformer {
	
	
	
	public ResolveSyntaxPredicates() {
		super("Resolve syntax predicates");
	}
	
	
	@Override
	public ASTNode transform(Configuration node) throws TransformerException {
		return node;
	}
	
	@Override
	public ASTNode transform(Syntax node) throws TransformerException {
		return node;
	}
	
	@Override
	public ASTNode transform(Sentence node) throws TransformerException {
		boolean change = false;
		Set<Variable> vars = MetaK.getVariables(node.getBody());
		ListOfK ands = new ListOfK();
		Term condition = node.getCondition();
		if (null != condition) {
			ands.getContents().add(condition);
		}
		for (Variable var : vars) {
//			if (!var.isUserTyped()) continue;
			if (MetaK.isKSort(var.getSort())) continue;
			change = true;
			ands.getContents().add(getPredicateTerm(var));
		}
		if (!change) return node;
		if (ands.getContents().size() > 1) {
			condition = new KApp(new Constant("KLabel", "'#andBool"), ands);
		} else {
			condition = ands.getContents().get(0);
		}
		node = node.shallowCopy();
		node.setCondition(condition);
		return node;
	}

	private Term getPredicateTerm(Variable var) {
		return new KApp(new Constant("KLabel", "is" + var.getSort()), var);
	}

}
