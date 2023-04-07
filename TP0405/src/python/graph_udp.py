
import datetime as dt
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import socket

import random

# Creation de la figure pour affichage
fig = plt.figure()
ax = fig.add_subplot(1, 1, 1)
valx = []
valy = []

AdresseEcoute = ("127.0.0.1", 7777)
datagramSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
datagramSocket.bind(AdresseEcoute)
# message, AdrSource = datagramSocket.recvfrom(128)

# Fonction de mise à jour de la liste des valeurs à chaque appel par la fonction d'annimation
def animate(i,valx,valy):
    # ici les données sont obtenues par génération aléatoire (entre 0 et 20)
    message, AdrSource = datagramSocket.recvfrom(128)
    messageString = message.decode("utf-8")
    val = int(messageString)
    # date de génération de la valeur pour l'axe des x
    valx.append(dt.datetime.now().strftime('%H:%M:%S'))
    # valeur générée pour l'axe des Y
    valy.append(val)
    # nettoyage du graphe 
    ax.clear()
    # Traçage des 20 dernières valeurs         
    ax.plot(valx[-20:],valy[-20:],'o-', label= 'my data')
    
    # Mise en fore du graphe
    plt.xticks(rotation=45, ha='right')
    plt.subplots_adjust(bottom=0.30)
    plt.title('Affichage de valeurs aléatoire entre 0 et 20')
    plt.ylabel('Valeurs ...')

# Définition de l'animation du graphe faisant appel à la fonction animate toutes
# les 500 ms.
ani = animation.FuncAnimation(fig, animate, fargs=(valx, valy), interval=500)
# Fenetre du graphe.
plt.show()



