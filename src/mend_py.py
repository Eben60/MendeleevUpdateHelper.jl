from mendeleev import element
print(element(17).name)
# print(element(17).ionic_radii)
#   print(element("Si").en_mulliken)
Si = element('Si')
# Si.en_mulliken()
print(Si.electronegativity('mulliken'))
print(Si.electronegativity('li-xue', charge=4))
