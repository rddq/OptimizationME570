function [weight, Stress] = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, Elem)

volume = 0.;
Kelem = zeros(nelem,4,4);
Kglob = zeros(ndof,ndof);
Kindex = 1:ndof;


% find length, cosine and sine of element
for k = 1:nelem
   ind1 = Elem(k,1);
   x1 = Node(ind1,1);
   y1 = Node(ind1,2);
   ind2 = Elem(k,2);
   x2 = Node(ind2,1);
   y2 = Node(ind2,2);
   length = ((x2-x1)^2 + (y2-y1)^2)^0.5;
   ecos = (x2-x1)/length;
   esin = (y2-y1)/length;
   Elem(k,4) = length;
   Elem(k,5) = ecos;
   Elem(k,6) = esin;
end

% compute element stiffness matrix
for k = 1:nelem
   ecos = Elem(k,5);
   esin = Elem(k,6);
   area = Elem(k,3);
   length = Elem(k,4);
   volume = volume + area * length;
   aEovrl = area*E/length;
   Kelem(k,1,1) = ecos^2 * aEovrl;
   Kelem(k,1,2) = ecos*esin * aEovrl;
   Kelem(k,1,3) = -ecos^2 * aEovrl;
   Kelem(k,1,4) = -ecos*esin * aEovrl;
   Kelem(k,2,1) = ecos*esin * aEovrl;
   Kelem(k,2,2) = esin^2 * aEovrl;
   Kelem(k,2,3) = -ecos*esin * aEovrl;
   Kelem(k,2,4) = -esin^2 * aEovrl;
   Kelem(k,3,1) = -ecos^2 * aEovrl;
   Kelem(k,3,2) = -ecos*esin * aEovrl;
   Kelem(k,3,3) = ecos^2 * aEovrl;
   Kelem(k,3,4) = ecos*esin * aEovrl;
   Kelem(k,4,1) = -ecos*esin * aEovrl;
   Kelem(k,4,2) = -esin^2 * aEovrl;
   Kelem(k,4,3) = ecos*esin * aEovrl;
   Kelem(k,4,4) = esin^2 * aEovrl;
   K(1:4,1:4)= Kelem(k,1:4,1:4);
end

% assemble global stiffness matrix
for k = 1:nelem
   ind1 = Elem(k,1);
   dof(1) = Node(ind1,3);
   dof(2) = Node(ind1,4);
   ind2 = Elem(k,2);
   dof(3) = Node(ind2,3);
   dof(4) = Node(ind2,4);
   for i = 1:4
      for j = 1:4
         Kglob(dof(i),dof(j))= Kglob(dof(i),dof(j)) + Kelem(k,i,j);
      end
   end
end


% copy the global stiffness matrix (done just for inspection purposes)
Ksolv(1:ndof,1:ndof) = Kglob(1:ndof, 1:ndof);

% apply the boundary conditions
nsolv = ndof - nbc;
for k = 1:nbc
   del = bc(k);
   Ksolv(:, del) = [];
   Ksolv(del, :) = [];
   Kindex(del) = [];
   force(del) = [];
end

% solve for nonzero displacements
qsolv = Ksolv\force;


% build total displacement vector
q = zeros(ndof,1);
for k = 1:nsolv
   q(Kindex(k)) = qsolv(k);
end
q;


% solve for stresses
for k = 1:nelem
   ind1 = Elem(k,1);
   dof(1) = Node(ind1,3);
   dof(2) = Node(ind1,4);
   ind2 = Elem(k,2);
   dof(3) = Node(ind2,3);
   dof(4) = Node(ind2,4);
   ltog = [-Elem(k,5), -Elem(k,6), Elem(k,5), Elem(k,6)];
   lq = [q(dof(1)); q(dof(2)); q(dof(3)); q(dof(4))];
   Stress(k) = E/Elem(k,4)*ltog*lq;
end

weight = volume*dens;
end
   




    
