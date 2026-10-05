#!/usr/bin/env python3
"""Generate semantic HTML, social metadata, canonical links and a sitemap.
Uses the same persisted content JSON as the Flutter apps. Drafts are excluded.
"""
import argparse, json, html, pathlib, urllib.parse, shutil, xml.etree.ElementTree as ET

def esc(value): return html.escape(str(value or ''), quote=True)
def public(rows): return sorted((r for r in rows.values() if r.get('status','published')=='published'),key=lambda r:r.get('order',0))
def safe_image(value):
 if value.startswith('packages/'): return '/assets/'+value
 if value.startswith(('data:image/png;base64,','data:image/jpeg;base64,','data:image/webp;base64,')):return value
 return value if value.startswith(('https://','http://','/')) else ''

def render(content,route='/',project=None):
 p=content['profile'];collections=content['collections'];name=p.get('name','Ahmed Emara');origin=p.get('siteUrl','').rstrip('/')
 title=(project.get('seoTitle') or project['title']+' — '+name) if project else (('Projects — '+name) if route=='/projects' else p.get('seoTitle',name+' — Flutter Developer'))
 description=(project.get('seoDescription') or project['description']) if project else p.get('seoDescription','')
 canonical=origin+route if origin else ''
 image=p.get('socialImage','')
 if image.startswith('/'):image=origin+image
 links=public(collections.get('social_links',{}))
 person={'@context':'https://schema.org','@type':'Person','name':name,'jobTitle':p.get('professionalTitle',p.get('badge','Flutter Developer')),'url':origin,'email':p.get('contactEmail',''),'sameAs':[r['url'] for r in links if r.get('url','').startswith('https://')]}
 css='''body{margin:0;background:#f6f5f0;color:#192e2b;font:16px/1.8 system-ui,sans-serif}main{max-width:1040px;margin:auto;padding:40px 24px}a{color:#08786f}h1{font-size:clamp(40px,7vw,76px);line-height:1.1;letter-spacing:-2px}h2{font-size:32px;line-height:1.2;margin-top:64px}h3{font-size:23px}nav{display:flex;gap:24px;flex-wrap:wrap}article{border-top:1px solid #d9ded6;padding:24px 0}img{max-width:220px;height:360px;object-fit:contain;margin:16px;background:#e6eee8}small{color:#5b6b65}.links{display:flex;gap:24px;flex-wrap:wrap}footer{margin-top:64px}'''
 css+='nav{align-items:center}nav .brand{display:inline-flex;align-items:center;gap:12px;color:#192e2b;font-weight:700;text-decoration:none}nav .brand img{width:48px;height:48px;max-width:none;object-fit:contain;margin:0;border-radius:10px;background:white}'
 def store_links(project):
  pairs=[('Google Play',project.get('googlePlayUrl')),('App Store',project.get('appStoreUrl')),('Website',project.get('liveUrl')),('Source code',project.get('codeUrl'))]
  pairs += [(l.get('label','View'),l.get('url')) for l in project.get('additionalLinks',[])]
  return '<div class="links">'+''.join(f'<a href="{esc(u)}">{esc(label)}</a>' for label,u in pairs if u and u.startswith(('https://','http://')) )+'</div>'
 def project_card(pr):
  url='/projects/'+urllib.parse.quote(pr.get('slug') or pr['id'])
  media=pr.get('gallery',[])[:2]
  images=''.join(f'<img loading="lazy" src="{esc(safe_image(e.get("thumbnail") or e.get("url","")))}" alt="{esc(e.get("alt",""))}" width="220" height="360">' for e in media if safe_image(e.get('thumbnail') or e.get('url','')))
  return f'<article><small>{esc(pr.get("category"))}</small><h3><a href="{url}">{esc(pr["title"])}</a></h3><p>{esc(pr.get("description"))}</p>{images}{store_links(pr)}</article>'
 projects=[{'id':key,**value} for key,value in collections.get('projects',{}).items() if value.get('status','published')=='published']
 projects.sort(key=lambda r:r.get('order',0))
 body=f'<main id="portfolio-fallback"><nav aria-label="Portfolio"><a class="brand" href="/"><img src="/assets/packages/core/assets/brand/logo.png" width="48" height="48" alt="" decoding="async"><span>{esc(name)}</span></a><a href="/projects">Projects</a><a href="mailto:{esc(p.get("contactEmail"))}">Contact</a>'
 if p.get('cvUrl'):body+=f'<a href="{esc(p["cvUrl"])}" download>Download CV</a>'
 body+='</nav>'
 if project:
  body+=f'<h1>{esc(project["title"])}</h1><p>{esc(project.get("description"))}</p>{store_links(project)}'
  for label,key in [('Product overview','overview'),('Intended users','audience'),('My role & contribution','role'),('Technical challenges','challenges'),('Implementation decisions','decisions'),('Outcomes','outcomes')]:
   if project.get(key):body+=f'<h2>{esc(label)}</h2><p>{esc(project[key])}</p>'
  if project.get('features'):body+='<h2>Features & user journeys</h2><ul>'+''.join(f'<li>{esc(f)}</li>' for f in project['features'])+'</ul>'
  if project.get('technologies'):body+='<h2>Technologies & integrations</h2><p>'+esc(' · '.join(project['technologies']))+'</p>'
  body+='<h2>Screenshots</h2>'+''.join(f'<img loading="lazy" src="{esc(safe_image(e.get("url","")))}" alt="{esc(e.get("alt",""))}" width="220" height="360">' for e in project.get('gallery',[]) if safe_image(e.get('url','')))
 else:
  body+=f'<h1>{esc(name) if route=="/" else "Selected mobile applications"}</h1><p>{esc(p.get("professionalTitle","Flutter Developer"))} · {esc(p.get("contactLocation"))}</p>'
  if route=='/':
   body+=f'<p>{esc(p.get("heroDescription"))}</p><p>'+esc(' · '.join(r.get('value','')+' '+r.get('label','') for r in public(collections.get('stats',{}))))+'</p><h2>Selected work</h2>'
   selected=sorted([pr for pr in projects if pr.get('featured')],key=lambda r:r.get('featuredOrder',0))[:4]
  else:selected=projects
  body+=''.join(project_card(pr) for pr in selected)
  if route=='/':
   body+='<h2>Professional experience</h2>'
   for e in public(collections.get('experiences',{})):
    body+=f'<article><small>{esc(e.get("period"))}</small><h3>{esc(e.get("title"))} · {esc(e.get("company"))}</h3><p>{esc(e.get("description"))}</p><ul>'+''.join(f'<li>{esc(a)}</li>' for a in e.get('achievements',[]))+'</ul></article>'
   body+='<h2>Open-source Flutter packages</h2>'
   for r in public(collections.get('packages',{})):body+=f'<article><h3>{esc(r.get("name"))}</h3><p>{esc(r.get("description"))}</p><a href="{esc(r.get("url"))}">View on pub.dev</a></article>'
   body+='<h2>Technical capabilities</h2>'
   for r in public(collections.get('technical_skills',{})):body+=f'<article><h3>{esc(r.get("name"))}</h3><p>{esc(r.get("description"))}</p><p>{esc(" · ".join(r.get("items",[])))}</p></article>'
   body+=f'<h2>{esc(p.get("aboutTitle"))}</h2><p>{esc(p.get("aboutDescription"))}</p>'
   for r in public(collections.get('education',{})):body+=f'<p>{esc(r.get("title"))} · {esc(r.get("institution"))} · {esc(r.get("period"))}</p>'
 body+=f'<footer><h2>Contact</h2><a href="mailto:{esc(p.get("contactEmail"))}">{esc(p.get("contactEmail"))}</a></footer></main>'
 # JSON encodes user data; escape script terminators to prevent HTML injection.
 structured=json.dumps(person,ensure_ascii=False).replace('<','\\u003c')
 return f'''<!DOCTYPE html>
<html lang="en"><head><base href="/"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{esc(title)}</title><meta name="description" content="{esc(description)}"><meta name="theme-color" content="#f6f5f0"><meta name="robots" content="index, follow">
<link rel="canonical" href="{esc(canonical)}"><link rel="icon" href="/favicon.png" type="image/png" sizes="64x64"><link rel="apple-touch-icon" href="/icons/apple-touch-icon.png" sizes="180x180"><link rel="manifest" href="/manifest.json">
<meta property="og:type" content="{'article' if project else 'website'}"><meta property="og:site_name" content="{esc(name)} — Portfolio"><meta property="og:title" content="{esc(title)}"><meta property="og:description" content="{esc(description)}"><meta property="og:url" content="{esc(canonical)}">{f'<meta property="og:image" content="{esc(image)}">' if image else ''}
<meta name="twitter:card" content="{'summary_large_image' if image else 'summary'}"><meta name="twitter:title" content="{esc(title)}"><meta name="twitter:description" content="{esc(description)}">
<script type="application/ld+json">{structured}</script><style>{css}</style></head><body>{body}
<script>window.addEventListener('flutter-first-frame',()=>document.getElementById('portfolio-fallback')?.remove());</script>
<script src="/flutter_bootstrap.js" async></script></body></html>'''

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--content',default='packages/core/assets/content.json');parser.add_argument('--web-root',default='apps/portfolio/build/web');args=parser.parse_args()
 content=json.loads(pathlib.Path(args.content).read_text());root=pathlib.Path(args.web_root);root.mkdir(parents=True,exist_ok=True)
 # This directory contains generated route snapshots only. Recreate it so
 # unpublishing removes historical static case-study content as well.
 if (root/'projects').exists(): shutil.rmtree(root/'projects')
 routes=[('/',None),('/projects',None)]
 for id,pr in content['collections'].get('projects',{}).items():
  if pr.get('status','published')=='published':routes.append(('/projects/'+(pr.get('slug') or id),pr))
 for route,pr in routes:
  destination=root/'index.html' if route=='/' else root/route.lstrip('/')/'index.html'
  destination.parent.mkdir(parents=True,exist_ok=True);destination.write_text(render(content,route,pr))
 origin=content['profile'].get('siteUrl','').rstrip('/')
 namespace='http://www.sitemaps.org/schemas/sitemap/0.9';ET.register_namespace('',namespace);sitemap=ET.Element('{'+namespace+'}urlset')
 for route,_ in routes:
  entry=ET.SubElement(sitemap,'{'+namespace+'}url');ET.SubElement(entry,'{'+namespace+'}loc').text=origin+route
 ET.ElementTree(sitemap).write(root/'sitemap.xml',encoding='utf-8',xml_declaration=True)
 (root/'robots.txt').write_text('User-agent: *\nAllow: /\nDisallow: /admin/\n'+(f'Sitemap: {origin}/sitemap.xml\n' if origin else ''))
 print(f'Generated {len(routes)} published pages and sitemap. No drafts were exported.')
if __name__=='__main__':main()
